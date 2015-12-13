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

Create_OU
 
 

function Create_Users {
    
    ### Chemin vers le fichier contenant les comptes"
    $fichier="C:\content.txt"


    ### Parcours du fichier ###
    if (Test-Path $fichier){
        $colLIgnes=Get-Content $fichier
    
        foreach($ligne in $colLignes){
            $tabCompte=$ligne.Split("/")
            $var2=""+$tabCompte[1]+"";
            
            
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