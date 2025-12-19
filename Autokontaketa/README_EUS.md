# autoconversacion.sh

**Mistral-ekin Elkarrizketa Script-a**

Script honek Mistral hizkuntza-modeloarekin elkarrekintza egitea ahalbidetzen du `llama-cli` bidez elkarrizketa enpatiko eta errealistak sortzeko. Adimen artifizialaren sormena esaldi ausazko sorkuntza-sistema batekin konbinatzen du, subjektu, aditz, ekintza, osagarri eta emozioak integratzen dituena, elkarrizketa gizatiarragoak eta askotarikoagoak lortuz. Gainera, script-ak elkarrekintzaren historiala mantentzen du eta fitxategi temporalak modu automatikoan kudeatzen ditu, lan-fluxua garbia eta segurua dela bermatuz.

## Funtzionalitatea

Script-ak esaldi ausazkoak sortzen ditu kontu handiz hautatutako elementu linguistikoen konbinazio batetik abiatuta, emozioak eta testuingurua transmititzeko. Exekuzio bakoitzak esaldi berriak sortzen ditu memoria-fitxategi batean (`MEMORIA`) gordetzen direnak, modeloak historiari erreferentzia egiteko eta erantzun koherenteak eta testuinguru aberastuak sortzeko aukera emanez.

Bi elkarrekintza-txanda egiten dira exekuzio bakoitzeko: lehenak hasierako esaldia sortzen du eta modeloaren erantzuna lortzen du, eta bigarrenak elkarrizketaren historiala erabiltzen du elkarrizketan jarraitutasuna eta sakontasuna sortzeko.

Exekuzioan sortutako fitxategi temporal guztiak automatikoki ezabatzen dira amaitzean, datuen metaketa saihestuz eta ingurune garbia mantenduz (`TEMP_DIR`).

## Erabilera

Script-a exekutatzeko, lehenik egin ezazu exekutagarri `chmod +x autoconversacion.sh` erabiliz.

Gero, abiarazi script-a `./autoconversacion.sh` terminaletik.

Exekuzioaren zehar, funtzionamendu egokia bermatzeko beharrezko bideak eskatuko dira: modeloaren kokapena (`MODELO_PATH`), exekuzio-binarioa (`MAIN_BINARY`), elkarrizketaren memoria gordeko den fitxategia (`MEMORIA`) eta direktorio temporala (`TEMP_DIR`).

Behin amaituta, sortutako elkarrizketa zuzenean kontsultatu ahal izango duzu kontsolan eta historila osoa berrikusi memoria-fitxategian. Honek elkarrizketaren jarraitutasuna jarraitzea eta datuak etorkizuneko exekuzioetarako berrerabiltzea ahalbidetzen du.

## Eskakizunak

Script-a macOS-en exekutatzeko diseinatuta dago Bash 5 edo handiagoarekin.

Beharrezkoa da Mistral modeloa `.gguf` formatuan eta `llama-cli` binarioa behar bezala konpilatuta eta funtzionala izatea.

Gomendagarria da CPU eta memoria baliabide nahikoak izatea modeloak prompt-ak modu eraginkorrean prozesatzeko, batez ere saio luzeetan.

## Kontuan hartzekoak

Script hau testu-sorkuntzarako esperimentuentzat, elkarrizketen simulazioentzat, hizkuntza-modeloen probetarako eta eduki interaktiboen sorkuntzarako oso erabilgarria da.

Gomendagarria da memoria-fitxategia aldian-aldian berrikustea koherentzia ebaluatzeko eta `llama-cli`-ko sorkuntza-parametroak behar izanez gero doitzeko.

Diseinu modularrak esaldiak sortzeko funtzioak zabaltzea, subjektu, aditz edo emozioak gehitzea eta elkarrekintzaren portaera pertsonalizatzea ahalbidetzen du logika zentrala aldatu gabe.

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic
