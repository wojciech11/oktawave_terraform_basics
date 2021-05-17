resource "oktawave_sshKey" "my_key"{
	# Required: true
    # Type: string
	# ForceNew: true
    # Available values: string of available length that represent name of ssh key
	ssh_key_name="Terraform_AUTOTEST"
	
	# Required: true
    # Type: string
	# ForceNew: true
    # Available values: ssh-rsa key value
	ssh_key_value="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCg01FwpikwL3494DJdi2iCnEzSlw/37Qn46IQX0XxtaXhSo2lwxgd8c6ITEyva6vmsOC0lO+yAldxWWt9U0fDxmLnoAt96VLYXwfMmw/SxZT4GGtIOJO5lRqWwDj+ekccV6U8v7GOHidAOy6zJp9bSOUH7VGpOGBk0We3NE5+5C3RzCNBsQMhIf8opJrqQpor+FMaCBnT+c9OcnjsMS9/VsbIRvYqqPzh5QcK4YndjbWE1m1aPaZW34mFsrTK3bivVR10/CfGrDQkxxMrzlenaqL6BGWiwIFgwgzhVpbxzByGztim3JF8CTnIPJf3M+P9r03PnJJIYqtmwAJyH+Y6OV5jiDCkame3mbTqHHL+EC3FOSWB5NAzzifCvX36CBVwBd2qJgxssAcBHlZvgU7Zo/Hi+cCq5fZp2S2f8F3WCLjYk7XY0Dd65tPJtmrnud6SAM25pLbbQFlokVxcdiMQqyS4+43/O92bIDPUe7JV+3fZcJrULmJ+WxwB+DG1ZW0+ZaVzMATNfVX2Z56TvlGAWAAtDAqf7PWWfUxrYTA16OtxXCl34NemVW9fmuTtlnMZwMMFqjFjl1m3306LokLwT70dp/DobQ89NlUkDSUsHbULMbnOfmhuqY0faD+FG5YuKqOPV5IhpuVumAHPi1wBXgBeGzh9fuHjp9+YM7cREtQ==  user@computer"
}