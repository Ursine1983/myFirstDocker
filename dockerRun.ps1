<##
### Script to setup and start a docker network with a running webserver and database
###
##>

# Checks if the webserver is running and starts it if not, the calls the other modual check functions
Function checkForRun
{
    Param (
        [Parameter(Mandatory=$True)]
        [string]$DockerContainer
    )

    $selectedDockerContainer = (docker container inspect $DockerContainer)
    Write-Host ($selectedDockerContainer) -ForegroundColor Yellow

    if ($selectedDockerContainer.Count -gt 2) {
        Write-Host ($DockerContainer + " image already runing")  -ForegroundColor Green
    } else {
        Write-Host ("starting" + $DockerContainer + " image ...")  -ForegroundColor Green
        docker run -p 80:80/tcp -d --name webdev -v $(PWD)/app:/devVol webdev:v1
    }

    checkDB
    checkMyAdmin 
}

# Checks if MariaDB image exists and if it is running. If not it handles the setup and start
Function checkDB {
    $selectDBContainer = (docker images "mariadb" --quiet)
    if ($selectDBContainer.Count -gt 0) {
        Write-Host ("MariaDB image already runing")  -ForegroundColor Green
    } else {
        $dbContainer = (docker container inspect db)
        if ($dbContainer.Count -gt 2) {
            Write-Host ("MariaDB container exists ...")  -ForegroundColor Green
            Write-Host ("restarting MariaDB container ...")  -ForegroundColor Green
            docker container restart db 
        } else {
            Write-Host ("starting MariaDB image ...")  -ForegroundColor Green
            docker run --name db -e MYSQL_ROOT_PASSWORD=root -d mariadb:latest
        }
    }
}


# Checks if phpMyAdmin image exists and if it is running. If not it handles the setup and start
Function checkMyAdmin {
    $selectphpMyAdminContainer = (docker images "myadmin" --quiet)
    if ($selectphpMyAdminContainer.Count -gt 0) {
        Write-Host ("phpMyAdmin image already runing")  -ForegroundColor Green
    } else {
        $myAdminContainer = (docker container inspect myadmin)
        if ($myAdminContainer.Count -gt 2) {
            Write-Host ("phpMyAdmin container exists ...")  -ForegroundColor Green
            Write-Host ("restarting phpMyAdmin container ...")  -ForegroundColor Green
            docker container restart myadmin 
        } else {
            Write-Host ("starting phpMyAdmin image ...")  -ForegroundColor Green
            docker run --name myadmin -d --link db:db -p 8080:80 phpmyadmin/phpmyadmin
        }
    }
}


# checks if Dockerfile has already been built. If not it handles the build. 
Function checkForBuild
{
    Param (
        [Parameter(Mandatory=$True)]
        [string]$DockerImage
    )

    $selectedDockerImage = (docker images $DockerImage --quiet)

    if ($selectedDockerImage.Count -gt 0) {
        Write-Host ($DockerImage + " image already exists")  -ForegroundColor Green
    } else {
        docker build -t webdev:v1 .
    }

    $DockerContainer = 'webdev'
    checkForRun $DockerContainer
}

# Name of the Dockerfile image for use in the network
$DockerImage = 'webdev'
# start the setup process
checkForBuild $DockerImage