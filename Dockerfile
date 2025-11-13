ARG AWX_EE_TAG=latest
ARG AWX_EE_REVISION=1

FROM registry.sfgitlab.opr.statefarm.org/registry/sfcommunity/sf-common-files:2.0.0 AS common-files
FROM packages.ic1.statefarm/quay-io-remote/ansible/awx-ee:${AWX_EE_TAG}

###############################
# Add SF Internal Certificates
###############################
COPY --from=common-files /ssl/sf-bundle.crt /ssl/sfpki.crt /opt/cst/
COPY --from=common-files /scripts /opt/sf_scripts/

###############################################
# Fix for Superconfig SCP SHA1 (requires root)
###############################################
USER root
RUN update-crypto-policies --set DEFAULT:SHA1

###########################################################
# Create runner user (UID 1000) and group if not present
# AAP expects the runner user to own /runner
###########################################################
RUN id -u 1000 &>/dev/null || useradd -u 1000 -m runner

###############################################
# Ensure correct permissions for runner user
###############################################
RUN chown -R 1000:1000 /home/runner \
    && mkdir -p /runner \
    && chown -R 1000:1000 /runner

###############################################
# Copy custom Ansible content (roles/modules/plugins)
###############################################
USER 1000

# Internally developed roles
ADD sfroles /etc/ansible/roles

# Internet-supported modules
ADD modules /home/runner/.ansible/plugins/modules

# Internally developed filter plugins
ADD sf_filter_plugins /home/runner/.ansible/plugins/filter

###############################################
# Python Requirements
###############################################
USER root
COPY requirements.txt /runner/requirements.txt
RUN mkdir -p /root/.local

RUN --mount=type=secret,id=pip_conf,dst=/etc/pip.conf \
    python3 -m pip install --user -r /runner/requirements.txt

###############################################################
# Fix Python package permissions (so runner user can access)
###############################################################
RUN chown -R 1000:1000 /root/.local

###############################################
# Switch to final runtime user (UID 1000)
###############################################
USER 1000

WORKDIR /runner
