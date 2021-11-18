FROM quay.io/operator-framework/ansible-operator:v1.14

USER root

ADD  google-sdk.repo /etc/yum.repos.d/google-cloud-sdk.repo

RUN dnf install -y yum-utils && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    dnf install terraform vim sed git sudo google-cloud-sdk -y

USER ${USER_ID}

# TODO git-sync
RUN mkdir /tf-repo && \
    git clone https://github.com/lukasz-bielinski/automated-infra-terraform.git /tf-repo

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible \
 && chmod -R ug+rwx /opt/ansible \
 && ln -s ${HOME}/.ansible /.ansible

RUN chmod -R 777 /opt/ansible && \
    chmod -R 777 /tf-repo

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
