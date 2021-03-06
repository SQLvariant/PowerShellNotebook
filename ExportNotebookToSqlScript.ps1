function Export-NotebookToSqlScript {
    <#
        .SYNOPSIS
        Exports all code blocks from a SQL Notebook to a SQL script

        .DESCRIPTION
        Exports from either a local notebook or one on the internet

        .Example
        Export-NotebookToSqlScript .\BPCheck.ipynb
        Get-Content .\BPCheck.SQL

        Converts a local copy of the BPCheck.ipynb Jupyter Notebook into a .SQL file, and gets the content of the 
        resulting .SQL file.

        .Example
        Export-NotebookToSqlScript "https://raw.githubusercontent.com/microsoft/tigertoolbox/master/BPCheck/BPCheck.ipynb"
        Get-Content .\BPCheck.sql

        Downloads the latest version of the BPCheck Jupyter Notebook from the TigerToolbox repository, converts it 
        into a .SQL file (named BPCheck.SQL), and gets the content.

        .Example
        Export-NotebookToSqlScript "https://raw.githubusercontent.com/microsoft/tigertoolbox/master/BPCheck/BPCheck.ipynb"
        Open-EditorFile .\BPCheck.sql

        Downloads the latest version of the BPCheck Jupyter Notebook from the TigerToolbox repository, converts it 
        into a .SQL file (named BPCheck.SQL), and when run from the PowerShell Integrated Console (in either VS Code or 
        Azure Data Studio), opens it as a new Notebook window.
        #>
    [CmdletBinding()]
    param(
        $FullName,
        $outPath = "./"
    )
    Write-Progress -Activity "Exporting SQL Notebook" -Status $FullName
    
    if ([System.Uri]::IsWellFormedUriString($FullName, [System.UriKind]::Absolute)) {
        $outFile = $FullName.split('/')[-1]
    }
    else {
        $outFile = (Split-Path -Leaf $FullName)
    }
    
    $outFile = $outFile -replace ".ipynb", ".sql"
    $fullOutFileName = $outPath + $outFile

    $heading = @"
/*
    Created from: $($FullName)

    Created by: Export-NotebookToSqlScript
    Created on: $(Get-Date)    
*/

"@ 

    $heading | Set-Content $fullOutFileName    
    $result = foreach ($sourceBlock in Get-NotebookContent $FullName) 
    {
        switch ($sourceBlock.Type) {
            'code'     {($sourceBlock.Source)}
            'markdown' {"/* "+($sourceBlock.Source)+" */"}
        }
        
        ""
    }

    $result | Add-Content  $fullOutFileName

    Write-Verbose "$($outFile) created"
}