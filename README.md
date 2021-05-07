## Oktawave Terraform

1. Zainstaluj Terraform 0.12.x (see https://releases.hashicorp.com/terraform/ for releases):

   ```
   $ export UNAME=darwin
   $ wget https://releases.hashicorp.com/terraform/0.12.30/terraform_0.12.30_${UNAME}_amd64.zip
   $ unzip terraform_0.12.30_${UNAME}_amd64.zip && rm terraform_0.12.30_${UNAME}_amd64.zip
   $ export PATH=$(pwd):${PATH}
   
   $ terraform --version
   Terraform v0.12.30
   ```
   
   W tym momencie Oktawave wspiera Teraforma 0.12.x, w przyszłości będzie prawdopodobie wspierał nowe wersje Terraforma.

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

   Przejwij dzialanie programu `ctr^C` on \*nix platform.

   Skąd to się wzieło? Sprawdźmy:

   ```
   $ cat provider.tf
   ```

4. Zanim utworzymy naszą pierwszą maszynę wirtualną za pomocą Terraforma na Oktaweave, musimy ściąnąć token. Skorzystajmy z ofinacjnej dokumentacji https://docs.oktawave.com/docs/services/terraform : 

   ```
   # twoje dane do logowanie do panelu oktawave
   $ export OW_USER=
   $ export OW_PASSWORD=
   
   # do utworzenia w https://id.oktawave.com/core/en/clients
   # pamiętaj, żeby wybrać "Scope of access: oktawave.api (read and modify)"
   $ export OW_API_CLIENT_ID=
   $ export OW_API_CLIENT_SECRET=
   
   $ curl -k -X POST -d "scope=oktawave.api&grant_type=password&username=${OW_USER}&password=${OW_PASSWORD}" \
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

7. Czas utworzyć maszynę wirtualną z Terraformem, dodaj do `provider.tf` lub dowolnego pliku z rozszerzeniem `.tf`, np., oktawave.tf:

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
     subregion_id = 6
   
     # INSTANCE CLASS & OS TYPE:
     type_id     = 1047
     template_id = 452
     
     # INSTANCES COUNT:
     instances_count = 1
     
     # FREEMIUM PLAN (IF AVAILABLE):
     isfreemium = false
   }
   ```

   Na podstaie: https://docs.oktawave.com/docs/services/terraform , jest to równoważne z utworzeniem instacji na https://admin.oktawave.com/en/YOUR_ACCOUNT/oci/create.

   [Dodatkowe] Pytanie, co wpisać w każde z pół, tu z pomocą przychodzi nam api oktawave ze słownikiem:

   ```
   $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       'https://pl1-api.oktawave.com/services/dictionaries/'

    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       'https://pl1-api.oktawave.com/services/dictionaries/' | jq 

    # znajdzmy wartość dla authorization_method_id
    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       'https://pl1-api.oktawave.com/services/dictionaries/' | jq | \
       grep -B 1 'Instance authorization methods'

    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/dictionaries/159' | jq

    # disk class? 
    $ curl -X GET \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
       'https://pl1-api.oktawave.com/services/dictionaries/' | jq | \
       grep -B 1 'Disk'

    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/dictionaries/17' | jq

# sprawdzenie dostępnych ID szablonów (template_id)
    $ curl -X GET --header 'Accept: application/json' \
      --header "Authorization: Bearer ${TF_VAR_oktawave_access_token}" \
      'https://pl1-api.oktawave.com/services/templates' |jq
   ```

   Jak znaleźć właściwe wartości korzystając z https://pl1-api.oktawave.com/services/docs/index#!/Account/Account_GetSshKeys:

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

11. Zauwawż, że pojawił się nowy plik:

    ```
    $ ls 
    
    terraform.tfstate
    ``` 
    
    Co on zawiera?

12. Warto znać:

    ```
    # automatyczne formatowanie kodu terraforma
    $ terraform fmt
    ```

13. Czas posprzątać po sobie:

    ```
    $ terraform destroy
    ```
