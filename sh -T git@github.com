error: numero di argomenti errato, dovrebbero essere da 1 a 2
uso: git config [<opzioni>]

Percorso file di configurazione
    --global              usa il file di configurazione globale
    --system              usa il file di configurazione di sistema
    --local               usa il file di configurazione del repository
    --worktree            usa il file di configurazione per albero di lavoro
    -f, --file <file>     usa il file di configurazione specificato
    --blob <ID blob>      leggi la configurazione dall'oggetto blob specificato

Azione
    --get                 ottenere valore: nome [value-pattern]
    --get-all             ottenere tutti i valori: key [value-pattern]
    --get-regexp          ottenere i valori per la regexp: name-regex [value-pattern]
    --get-urlmatch        ottieni il valore specifico per l'URL: sezione[.variabile] URL
    --replace-all         sostituisce tutte le variabili corrispondenti: nome valore [modello di valore].
    --add                 aggiungi una nuova variabile: nome valore
    --unset               rimuove una variabile: name [value-pattern].
    --unset-all           rimuove tutte le corrispondenze: nome [valore-modello].
    --rename-section      rinomina sezione: vecchio-nome nuovo-nome
    --remove-section      rimuovi una sezione: nome
    -l, --list            elenca tutti
    --fixed-value         utilizzare l'uguaglianza delle stringhe quando si confrontano i valori con "modello di valore".
    -e, --edit            apri un editor
    --get-color           trova il colore configurato: slot [valore-predefinito]
    --get-colorbool       trova l'impostazione colore: slot [standard-output-è-una-tty]

Tipo
    -t, --type <>         al valore è assegnato questo tipo
    --bool                il valore è "true" o "false"
    --int                 il valore è un numero decimale
    --bool-or-int         il valore è --bool o --int
    --bool-or-str         il valore è --bool o una stringa
    --path                il valore è un percorso (nome file o directory)
    --expiry-date         il valore è una data di scadenza

Altro
    -z, --null            termina i valori con un byte NUL
    --name-only           visualizza solo i nomi delle variabili
    --includes            rispetta le directory di inclusione durante il recupero delle variabili
    --show-origin         visualizza l'origine del file di configurazione (file, standard input, blob, riga di comando)
    --show-scope          visualizza l'ambito della configurazione (albero di lavoro, locale, globale, sistema, comando)
    --default <valore>    con --get, usa il valore predefinito se la voce è mancante

