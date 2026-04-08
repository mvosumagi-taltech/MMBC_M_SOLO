# MMBC_M_SOLO — Claude Code juhised

## Projekt

MMBC_M_SOLO on Business Central AL laiendus säilivusaja pikendamise haldamiseks **SLE Document mooduliga** 

- **GitHub repo:** `https://github.com/mvosumagi-taltech/MMBC_M_SOLO`
- **Project board:** `https://github.com/users/mvosumagi-taltech/projects/6`
- **Lokaalne kaust:** `C:\Users\Mart_IT\git\MMBC_M_SOLO`
- **Publisher:** `ITB2204`
- **ID vahemik:** `59200–59249`

## Startup

1. Loe `docs/task-progress.md` kui see eksisteerib — seal on arenduse seis
2. Vaata project board: `https://github.com/users/mvosumagi-taltech/projects/6`
3. AL koodireeglid on `.github/copilot-instructions.md`

## Issue struktuur (project 6)

```
#1  MMBC — SLE Document mooduliga        [epic]
├── #2  F1 Seadistus                      → #10, #11, #12
├── #3  F2 Laiendused                     → #13, #14, #15, #16
├── #4  F3 Enumid ja MMBC Seadistus       → #17, #18, #19, #20
├── #5  F4 Pikendamispäring               → #21–#28
├── #6  F5 Pikendamisdokument             → #29–#34
├── #7  F6 Codeunitid                     → #35–#38
├── #8  F7 Tegevuste logi ja Aeguvad partiid → #39–#42
└── #9  F8 Raportid                       → #43–#48
```

## Reeglid

- Suhtluskeel: eesti keel
- Ära alusta koodi kirjutamist enne kui kasutaja ütleb "alustame"
- Kasuta `bc-al-developer` skillit AL objektide kirjutamisel
- Spawni AL Developer + AL Critic subagendid enne koodi kirjutamist
- DoD: ainult praeguse taski skoop; plain text issue viited (mitte hüperlingid)
- Välja ID-d (59200–vahemik) ei kirjutata issue-sse — kood on single source of truth
- Pärast koodi kirjutamist nimeta: "#XX valmis ülevaatuseks — \`src/...\`"
- jälgi, et taskid oleks arendatavad täismahus ilma järgmisi taske ootamata vajadusel tee taske mitmeks
