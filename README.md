# Azure Sensible

> :warning: Warning
> The Terraform script generates an SSH key for the Ansible admin account. The
> private key is [stored
> unencrypted](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)
> in the Terraform state file. This is not a secure if you intend on [sharing the
> terraform state](https://www.terraform.io/docs/state/remote.html) and should
> be replaced when building on this example.
