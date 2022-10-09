String translateError(String error) {
  switch (error) {
    case "connectionerr":
      {
        return "C'è stato un errore di connessione, riprova più tardi. ($error)";
      }

    case "probably404":
      {
        return "Generalmente non dovresti vedere questo, ma l'ultimo orario caricato.\nProva a controllare il link che hai impostato e riprova. ($error)";
      }

    case "firsttime":
      {
        return """
Sembra che sia la prima volta che apri questa applicazione.

Per iniziare vai sul sito della scuola e vai su:
Orario delle lezioni > Orario singole classi > la tua classe.

Copia il link ed incollalo in:
Impostazioni (l'ingranaggio in alto a sinistra) > Link orario scuola.
""";
      }

    default:
      {
        return "Evidentemente hai rotto tutto, così tanto che pure l'errore non è riconosciuto. Reinstalla l'app e riprova. ($error)";
      }
  }
}
