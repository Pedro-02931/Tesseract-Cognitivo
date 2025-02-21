function createDIRs() {
    <#
    1. Define the structure Map

    - In the first step, I create a hashtable to map the folder structure, which worn an as object that allows storing multiples superposition states in which:
        - The key is the folder name, and the value is an array containing the subfolder names.
        - The array is sorted in ascending order to maintain the correct order of folders.
        - Each subfolder name is a string.

    - This approach was strategic so that I could:
        - Add, remove, or modify folders and subfolders easily.
        - Keep the structure organized and easy to navigate.
    #>
    $structure = @{
        "Compras" = @(
            "Internas", 
            "Externas")
        "RH" = @(
            # Sem subpastas, array vazio
        )         
        "Informática" = @(
            "softwares",
            "documentos")
    }

    <#
    2. The first Propagation

    - I iterate over each folder in the $structure hashtable.
    - Inside the loop, I create the main nodule to map $mainPath.
    #>

    foreach ($folder in $structure.Keys) {
        $mainPath = "C:\$folder"
    }

    <#
    3. Is it alredy exists?

    - I used TestPath to check if folder already existed.
        - run `New-Item -Path \text{nó principal mapeado} -ItemType Directory -Force }

    - If exists...
        - Write-Host "Pasta já existe: $caminhoPrincipal"
    #>

    if (-not (Test-Path $caminhoPrincipal)) {
        New-Item -Path $caminhoPrincipal -ItemType Directory -Force
        Write-Host "Criada pasta: $caminhoPrincipal"
    } else {
        Write-Host "Pasta já existe: $caminhoPrincipal"
    }

    <#
    4. The second Propagation
    - I iterate over each subfolder in the $structure hashtable.

    - The same verification method is used.
    #>

    $caminhoSub = Join-Path -Path $caminhoPrincipal -ChildPath $sub
    if (-not (Test-Path $caminhoSub)) {
        New-Item -Path $caminhoSub -ItemType Directory -Force | Out-Null
        Write-Host "Criada subpasta: $caminhoSub"
    } else {
        Write-Host "Subpasta já existe: $caminhoSub"
    }
}


createDIRs()