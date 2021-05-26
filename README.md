## Oktawave Terraform

1. Zainstaluj Terraform 0.12.x (do pobrania z https://releases.hashicorp.com/terraform/):

   ```
   $ export UNAME=darwin
   $ wget https://releases.hashicorp.com/terraform/0.12.30/terraform_0.12.30_${UNAME}_amd64.zip
   $ unzip terraform_0.12.30_${UNAME}_amd64.zip && rm terraform_0.12.30_${UNAME}_amd64.zip
   $ export PATH=$(pwd):${PATH}

   $ terraform --version
   Terraform v0.12.30
   ```

   W tym momencie Oktawave wspiera Teraforma 0.12.x, w przyszłości będzie prawdopodobnie wspierał nowe wersje Terraforma.

2. Driver Oktawave nie jest jeszcze w oficjalnym repozytorium terraforma, więc musimy go zainstalować u siebie na komputerze:

   ```
   $ export UNAME=darwin
   $ wget https://github.com/oktawave-code/terraform-provider-oktawave/releases/download/v0.4.0/terraform_${UNAME}_amd64
   $ terraform_${UNAME}_amd64 terraform-provider-oktawave && chmod +x terraform-provider-oktawave

   # zobaczmy czy mamy wszystko gotowe:
   $ ls

   README.md  provider.tf  terraform  terraform-provider-oktawave
   ```

3. Sprawdźmy czy terraform widzi plugin:

   ```
   $ terraform plan

   provider.oktawave.access_token
     Enter a value:
   ```

   Przerwij działanie programu `ctr^C` on \*nix platform.

   Dlaczego zostaliśmy zapytanie o token? Sprawdźmy definicję providera wraz ze zmienną:

   ```
   $ cat provider.tf
   ```

4. Zanim utworzymy naszą pierwszą maszynę wirtualną za pomocą Terraforma na Oktaweave, musimy ściąnąć token. Skorzystajmy z oficjalnej dokumentacji https://docs.oktawave.com/docs/services/terraform :

   ```
   # twoje dane do logowanie do panelu oktawave
   $ export OW_USER=
   $ export OW_PASSWORD=

   # do utworzenia w https://id.oktawave.com/core/en/clients
   # pamiętaj, żeby wybrać "Scope of access: oktawave.api (read and modify)"
   $ export OW_API_CLIENT_ID=
   $ export OW_API_CLIENT_SECRET=

   $ curl -k -X POST \
       -d "scope=oktawave.api&grant_type=password&username=${OW_USER}&password=${OW_PASSWORD}" \
       -u "${OW_API_CLIENT_ID}:${OW_API_CLIENT_SECRET}" 'https://id.oktawave.com/core/connect/token'

   # powinieneś zobaczyć:
   {"access_token":"xxx808dxxx4c9fbc5e22483","expires_in":1086400,"token_type":"Bearer"}
   ```

5. Sprawdźmy czy działa:

   ```
   # przekopiuj wartość access_tokenu

   $ terraform plan

   provider.oktawave.access_token
     Enter a value: xxx808dxxx4c9fbc5e22483

   # powinieneś zobaczyć

   ------------------------------------------------------------------------

   No changes. Infrastructure is up-to-date.
   ```

6. Teraz, warto byłoby coś zrobić!

   ```
   # twój token będziemy przekazywać jako
   # zmienną środowiskową
   $ export TF_VAR_oktawave_access_token=xxx808dxxx4c9fbc5e22483

   $ terraform plan
   ```

   [Dodatkowe] Chmura to automatyzacja, aż się prosi zamiast copy&paste:

   ```
   $ export TF_VAR_oktawave_access_token=$(curl -s -k -X POST \
       -d "scope=oktawave.api&grant_type=password&username=${OW_USER}&password=${OW_PASSWORD}" \
       -u "${OW_API_CLIENT_ID}:${OW_API_CLIENT_SECRET}" 'https://id.oktawave.com/core/connect/token' \
       | jq '.access_token' | tr -d '"')
   ```

7. Czas utworzyć maszynę wirtualną za pomocą Terraforma, utwórz plik `oktawave.tf`, który w sposób deklaracyjny definiuje naszą pierwszą maszynę wirtualną:

   ```terraform
   resource "oktawave_oci" "my_oci" {

     # NAME:
     instance_name = "TERRAFORM_OCI"

     # OCI AUTH METOD:
     authorization_method_id = 1399

     # OVS (STORAGE) PARAMETERS:
     # disk class (tier)
     disk_class = 48

     # disk size
     init_disk_size = 5

     # IP ADDRESS:
     # Available values: id of ip address that you want to set as default
     # Comment: Replace default ip address that would be created as part of instance setup
     # If you comment this field, ip address will be computed & obtained by default
     # ip_address_id=id

     # SUBREGION ID:
     subregion_id = 7

     # INSTANCE CLASS & OS TYPE:
     type_id     = 1268
     template_id = 1021

     # INSTANCES COUNT:
     instances_count = 1

     # FREEMIUM PLAN (IF AVAILABLE):
     isfreemium = false
   }
   ```

   Na podstawie: https://docs.oktawave.com/docs/services/terraform , jest to równoważne z utworzeniem instancji na https://admin.oktawave.com/en/YOUR_ACCOUNT/oci/create.

   [Dodatkowe] Pytanie, co wpisać w każde z pół, tu z pomocą przychodzi nam api oktawave ze słownikiem:

   ```
   $ export OKTAWAVE_DICT_URL=https://pl1-api.oktawave.com/services/dictionaries

   $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       "${OKTAWAVE_DICT_URL}"

    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       "${OKTAWAVE_DICT_URL}" | jq

    # wartość dla authorization_method_id ?
    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       "${OKTAWAVE_DICT_URL}"  | jq | \
       grep -B 1 'Instance authorization methods'

    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      "${OKTAWAVE_DICT_URL}/159" | jq

    # disk class?
    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       "${OKTAWAVE_DICT_URL}" | jq | \
       grep -B 1 'Disk'

    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      "${OKTAWAVE_DICT_URL}/17" | jq

    # dostępnych ID szablonów (template_id)?
    $ curl -s -X GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/templates' | jq

    # z dodatkiem odrobiny magi jq zobaczmy
    # jakie OSy mamy do dyspozycji:
    $ curl -s -X GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/templates' | jq '.[] | .[] | .Name'

    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/templates' | jq | grep -i ubuntu

     # jaki mamy do wyboru Ubuntu
     $ curl -s -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/templates' | \
      jq '.[][] | select(.Name | contains("Ubuntu") )'
   ```

   Jak znaleźć właściwe wartości korzystając z [pl1-api.oktawave.com/services/docs/index#!/Account/Account_GetSshKeys](https://pl1-api.oktawave.com/services/docs/index#!/Account/Account_GetSshKeys):

8. Czy znasz to uczucie, kiedy chcesz utworzyć zasoby w chmurze ale nie wiesz jakie to konsekwencje za sobą niesie. Z terraformem nie musisz się bać:

   ```
   $ terraform plan
   # dokładnie widzisz co utworzysz:
   ```

9. Teraz czas utworzyć instancję

   ```
   $ terraform apply
   # dokładnie widzisz co utworzysz:
   ```

10. Przejdź do konsoli webowej, żeby zobaczyć, że instancja jest utworzona: https://admin.oktawave.com/en/YOUR_ACCOUNT/oci/instances

11. Zalogujmy się z pomocą hasła, znajdziesz je w panelu gdzie są detale twojej maszyny wirtualnej.

   ```
   $ ssh root@120018-1-168c65-01.services.oktawave.com

   root@120018-1-168c65-01:~# apt-get update; apt-get install -y nginx
   ```

   Zauważ: właściwym sposobem zabezpieczeniem logowanie jest użycie kluczy ssh. My tutaj operujemy na haśle i użytkowniku TYLKO dla uproszczenia. Poniżej, w dodatkowym zadaniu, znajdziesz informację jak wstrzyknąć swój klucz publiczny do maszyny wirtualnej.

   [Dodatkowe] Zainstalować i skonfigurować serwer www serwujący ruch na HTTPS.

12. Zauważ, że pojawił się nowy plik:

    ```
    $ ls

    terraform.tfstate
    ```

    Co on zawiera?

13. Warto znać:

    ```
    # automatyczne formatowanie kodu terraforma
    $ terraform fmt
    ```

13. Czas posprzątać po sobie:

    ```
    $ terraform destroy
    ```

14. [Dodatkowe] Jak dodać swój klucz publiczny ssh (`cat ~/.ssh/id_rsa.pub`), aby logować się za pomocą kluczy:

    1. Dodajemy klucz:

      ```terraform
      resource "oktawave_sshKey" "my_key"{
        # Required: true
        # Type: string
        # ForceNew: true
        # Available values: string of available length that represent name of ssh key
        ssh_key_name="my_ssh_pub_key"

        # Required: true
        # Type: string
        # ForceNew: true
        # Available values: ssh-rsa key value
        ssh_key_value="ssh-rsa AAAAB3NXXX==  user@computer"
      }
      ```

    2. Zmieniamy w definicji maszyny:

      ```terraform
      resource "oktawave_oci" "my_oci" {
        ...

        authorization_method_id="1398"

        ssh_keys_ids = [oktawave_sshKey.my_key.id]
        ...
      }
      ```
