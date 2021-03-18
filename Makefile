OCTAWAVE_TF_PROVIDER_VERSION=v0.4.0
# linux
UNAME_S=darwin

tf_install_octawave_provider:
	mkdir -p $${TF_OKTAWAVE_HOME} && \
	cd $${TF_OKTAWAVE_HOME} && \
 	wget https://github.com/oktawave-code/terraform-provider-oktawave/releases/download/$(OCTAWAVE_TF_PROVIDER_VERSION)/terraform_$(UNAME_S)_amd64 && \
	mv terraform_*_amd64 terraform-provider-oktawave && chmod +x terraform-provider-oktawave