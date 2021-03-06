Import-Module ActiveDirectory


function Create_OU {

    ### Création de l'OU "STAGE" ###
    
    if(([adsi]::Exists("LDAP://OU=stage,DC=maison,DC=loc"))) {
   
        Write-Host "L'unité d'organisation stage existe déjà"
    }
    else {
        NEW-ADOrganizationalUnit "stage"
    }
    
    
    
    ### Création de l'OU "bts" ###
    
    if(([adsi]::Exists("LDAP://OU=bts,OU=stage,DC=maison,DC=loc"))) {
   
        Write-Host "L'unité d'organisation bts existe déjà"
    }
    else {
        NEW-ADOrganizationalUnit "bts" -path "OU=stage,DC=maison,DC=loc"
    }
}
 
 

function Create_Users {
    
    ### Chemin vers le fichier contenant les comptes"
    $fichier="C:\content.txt"


    ### Parcours du fichier ###
    if (Test-Path $fichier){
        $colLIgnes=Get-Content $fichier
    
        foreach($ligne in $colLignes){
            $tabCompte=$ligne.Split("/")
            $var2=""+$tabCompte[1]+"";
            
            
            
            
            #################  CREATION DU REPERTOIRE PERSONNEL DES UTILISATEURS AVEC PERMISSIONS  #################
            
            ### Affectation du chemin du dossier users probable ###
            $homeDirectory = "E:\DATA\stages\bts\"+$tabCompte[0]+"";
           
          
            ### Test d'existence et création du dossier personnel des utilisateurs ainsi que ses permissions ###
            if (-not (Test-Path $homeDirectory)) {
            
                ### Le dossier n'existe pas donc ### Création du dossier personnel Ex:"E:\share\nomDuUser" ### Ajout d'acl sur le dossier (ajout des permissions du users sur son dossier personnel
                New-Item -ItemType directory  -Path $homeDirectory;
              
                $acl = Get-Acl -Path $homeDirectory;
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($tabCompte[1], "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule);
                Set-Acl -path $homeDirectory -AclObject $acl;   
            }
            else {
                Write-Host "Le dossier de"$tabCompte[0] "existe déjà"
            }
            
            
            
            #################  AJOUT DES LECTEURS RESEAUX SUR LES COMPTES DES UTILISATEURS  #################

            
            ### Chemin réseau du répertoire partagé de chaque users ###
            $PathNetworkUsers = "\\WIN-6GVVKKLNK5H\DATA\stages\bts\"+$tabCompte[0]+"";
            
            ### Affectation du lecteur aux users ###
            SET-ADUSER -Identity $tabCompte[1] -HomeDirectory $PathNetworkUsers -HomeDrive 'Z:' 
            
            

            
            ### Test d'existence du compte
            $checkUser = Get-ADUser -LDAPFilter "(sAMAccountName=$var2)"
                       
            if (!$checkUser) {
                New-ADUser -Name $tabCompte[0] -Path "OU=bts,OU=stage,DC=maison,DC=loc" -SamAccountName $tabCompte[1] -AccountPassword(ConvertTo-SecureString "P@sswordP@ssword" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enable $true;
            }
            else {
                Write-Host "Le nom d'utilisateur" $tabCompte[1] "existe déjà";
            }
        }
    }
}

Create_Users