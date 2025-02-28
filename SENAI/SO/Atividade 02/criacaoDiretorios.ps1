function () {
    <#
    - 1. I defined these main directories are the type of the entry nodes in the DAG.
        - It`s basically define the zero point of our vector space, where all segmentation will branch.
        - The logic here is to create an anchor on the Desktop, from which the all logical states (folders and files) will emerge. 
    #>
    $BASE_DIR   = Join-Path $env:USERPROFILE "Desktop\Usuarios"
    $PUBLIC_DIR = Join-Path $env:USERPROFILE "Desktop\Pasta_Pública"

    <#
    - 2. Using @(splatting), you create a dictionary of the parameters that will be used as the weights of the vertices in your graph.
        - This aproach transforms the code in to an almost matrix function, where DAG nodes receive parameters uniformly, whiout repeating code unnecessarily.
        - Here, we're defining the weight of each directory as 1, which means every directory will receive the same resources in the DAG.
        - It's  as if each directory was a "neuron" in a neural network in backpropagation.
        - Receiveng the same instructions as there is no inference decision, it only has a way of being executed.  
        - Created parameters rules for neurons
    #>
    $dirParams = @{
        ItemType = "Directory"
        Force    = $true
    }
    New-Item @dirParams -Path $BASE_DIR   
    New-Item @dirParams -Path $PUBLIC_DIR

    <#
    - 4. Here we place the vertices in the graph, creating unique users identifiers.
        -The use of @()reinforce the idea of an ordered set,where each element is  a node with a unidirectionalpath in the DAG.
        - Each node will create subdirectories nd files, mapping the system state in a matrix way.
    #>
    $users = @(1, 2, 3, 4)

    # Loop para criação das pastas e arquivos de cada usuário
    foreach ($u in $users) {
        $USER_DIR = Join-Path $BASE_DIR "usuario$u"
        New-Item @dirParams -Path $USER_DIR 

        <#
        - 5. Each user creates a two new dimentions (Documents and Downloads). 
            - creates subdirectories from envoiment variables
            - Segmentation allows resources to be accessed optimally, as if each subdirectory were a tensor accessed by a simple matrix operation.
            - This is a simple example of how to create a graph using PowerShell and the concept of a Directed Acyclic Graph (DAG).
            - The hole point is to transform system navigation into a collision-free operation , like a perfect hash 
        #>
        $docDir = Join-Path $USER_DIR "Documentos"
        $dlDir  = Join-Path $USER_DIR "Downloads"
        New-Item @dirParams -Path $docDir 
        New-Item @dirParams -Path $dlDir 

        <#
        - 6. Each terminal node(the *.txt files) contains data that validates the DAG cycle.\
            - It`s like the system's short-term memory, where each node carries with it a slice of reality(uder-data)
            - Here, we're creating two example files with user data.
            - The use of the Out-File cmdlet is a way to create files from strings in PowerShell.
            - We've created a persistent projection of the graph, where each file is a stable instance in the data flow
        #>
        "Informações do usuario$u" | Out-File -FilePath (Join-Path $docDir "info.txt") -Encoding UTF8
        "Dados do usuario$u"       | Out-File -FilePath (Join-Path $dlDir "dados.txt") -Encoding UTF8
    }


    Write-Host "Estrutura de diretórios criada com sucesso: " -ForegroundColor Green
    cmd /c "tree `"$BASE_DIR`" /F | more"
}