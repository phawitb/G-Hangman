import '../features/gameplay/domain/game_level.dart';
import '../features/localization/domain/app_language.dart';
import 'seed_levels.dart';

/// Translated content for one level (structure like difficulty/reward/scene is
/// reused from the English [kSeedLevels] entry with the same id).
class LevelText {
  const LevelText(this.category, this.clue, this.answer, this.explanation);
  final String category;
  final String clue;
  final String answer;
  final String explanation;
}

/// Builds the level list for a given language. English uses the full 100-level
/// bank; the other languages use their translated banks (extendable by adding
/// entries to the maps below). Each language keeps its own progress because the
/// [LevelRepository]/progress are keyed by language.
abstract final class LocalizedLevels {
  static List<GameLevel> forLanguage(AppLanguage lang) {
    if (lang == AppLanguage.english) return kSeedLevels;
    final content = _content[lang];
    if (content == null) return kSeedLevels;
    final byId = {for (final l in kSeedLevels) l.id: l};
    final ids = content.keys.toList()..sort();
    return [
      for (final id in ids)
        if (byId[id] != null)
          GameLevel(
            id: id,
            category: content[id]!.category,
            clue: content[id]!.clue,
            answer: content[id]!.answer,
            explanation: content[id]!.explanation,
            difficulty: byId[id]!.difficulty,
            maxMistakes: byId[id]!.maxMistakes,
            coinReward: byId[id]!.coinReward,
            alphabet: lang.alphabet,
          ),
    ];
  }

  static const Map<AppLanguage, Map<int, LevelText>> _content = {
    AppLanguage.german: _de,
    AppLanguage.swedish: _sv,
    AppLanguage.finnish: _fi,
  };

  // ---- German ---------------------------------------------------------------
  static const Map<int, LevelText> _de = {
    1: LevelText(
      'Tiere',
      'Welches Tier baut Dämme aus Ästen und Schlamm?',
      'BIBER',
      'Biber bauen Dämme aus Ästen, Schlamm und Steinen.',
    ),
    2: LevelText(
      'Essen',
      'Welche lange, gelbe, gebogene Frucht essen Affen gern?',
      'BANANE',
      'Bananen wachsen in Büscheln und stecken voller Kalium.',
    ),
    3: LevelText(
      'Natur',
      'Welcher bunte Bogen erscheint nach Regen und Sonne?',
      'REGENBOGEN',
      'Ein Regenbogen entsteht, wenn Licht in Tropfen bricht.',
    ),
    4: LevelText(
      'Alltag',
      'Was öffnest du, um im Regen trocken zu bleiben?',
      'REGENSCHIRM',
      'Ein Regenschirm spannt ein Dach über Speichen auf.',
    ),
    5: LevelText(
      'Tiere',
      'Welcher flugunfähige schwarz-weiße Vogel watschelt übers Eis?',
      'PINGUIN',
      'Pinguine können nicht fliegen, schwimmen aber toll.',
    ),
    6: LevelText(
      'Geografie',
      'Welches Land hat die großen Pyramiden und den Nil?',
      'ÄGYPTEN',
      'Ägypten liegt in Nordafrika am längsten Fluss, dem Nil.',
    ),
    7: LevelText(
      'Wissenschaft',
      'Welche unsichtbare Kraft zieht einen Apfel zu Boden?',
      'SCHWERKRAFT',
      'Die Schwerkraft zieht Massen zueinander.',
    ),
    8: LevelText(
      'Sport',
      'In welchem Schlägersport spielt man den Ball über ein Netz?',
      'TENNIS',
      'Tennis spielt man mit Schläger und Ball über ein Netz.',
    ),
    9: LevelText(
      'Tiere',
      'Welches Meerestier hat acht Arme mit Saugnäpfen?',
      'KRAKE',
      'Ein Krake hat acht Arme und ist erstaunlich klug.',
    ),
    10: LevelText(
      'Essen',
      'Welches flache, runde Frühstück brät man in der Pfanne?',
      'PFANNKUCHEN',
      'Pfannkuchen macht man aus Mehl, Ei und Milch.',
    ),
    11: LevelText(
      'Natur',
      'Welcher Berg kann ausbrechen und Lava spucken?',
      'VULKAN',
      'Ein Vulkan ist eine Öffnung, aus der Magma austritt.',
    ),
    12: LevelText(
      'Technik',
      'Womit tippt man Buchstaben in den Computer?',
      'TASTATUR',
      'Eine Tastatur wandelt Tastendruck in Zeichen um.',
    ),
    13: LevelText(
      'Tiere',
      'Welches kluge Meeressäugetier klickt und springt aus dem Wasser?',
      'DELFIN',
      'Delfine orientieren sich mit Klicklauten.',
    ),
    14: LevelText(
      'Alltag',
      'Welches Werkzeug mit zwei Klingen schneidet Papier?',
      'SCHERE',
      'Eine Schere schneidet mit zwei beweglichen Klingen.',
    ),
    15: LevelText(
      'Geografie',
      'Welches nördliche Land hat ein rotes Ahornblatt in der Flagge?',
      'KANADA',
      'Kanada ist das zweitgrößte Land der Erde.',
    ),
    16: LevelText(
      'Wissenschaft',
      'Welches Gas in der Luft brauchen wir zum Atmen?',
      'SAUERSTOFF',
      'Sauerstoff macht etwa 21% der Luft aus.',
    ),
    17: LevelText(
      'Tiere',
      'Welches ist das größte Landtier mit langem Rüssel?',
      'ELEFANT',
      'Elefanten greifen mit dem Rüssel nach Futter.',
    ),
    18: LevelText(
      'Geschichte',
      'In welchem befestigten Bau lebten Könige im Mittelalter?',
      'BURG',
      'Burgen hatten dicke Mauern und Türme zum Schutz.',
    ),
    19: LevelText(
      'Natur',
      'Welches Grollen folgt auf einen Blitz?',
      'DONNER',
      'Donner ist der Schall der Luft um einen Blitz.',
    ),
    20: LevelText(
      'Technik',
      'Welches weltweite Netz verbindet Computer überall?',
      'INTERNET',
      'Das Internet verbindet Milliarden Geräte weltweit.',
    ),
    21: LevelText(
      'Tiere',
      'Welche gefleckte Großkatze ist der schnellste Läufer an Land?',
      'GEPARD',
      'Ein Gepard rennt kurz bis zu 100 km/h.',
    ),
    22: LevelText(
      'Essen',
      'Welche cremige grüne Frucht wird zu Guacamole zerdrückt?',
      'AVOCADO',
      'Avocados stecken voller gesunder Fette.',
    ),
    23: LevelText(
      'Geografie',
      'Wie heißt der höchste Berg der Erde?',
      'EVEREST',
      'Der Mount Everest ist rund 8.849 Meter hoch.',
    ),
    24: LevelText(
      'Wissenschaft',
      'Was zieht Eisen an und hat Nord- und Südpol?',
      'MAGNET',
      'Magnete sind an ihren beiden Polen am stärksten.',
    ),
    25: LevelText(
      'Sport',
      'Welcher Langstreckenlauf ist etwa 42 Kilometer lang?',
      'MARATHON',
      'Der Marathon ist nach einem Ort in Griechenland benannt.',
    ),
    26: LevelText(
      'Alltag',
      'Welches Gerät hat eine Nadel, die nach Norden zeigt?',
      'KOMPASS',
      'Die Kompassnadel richtet sich am Erdmagnetfeld aus.',
    ),
    27: LevelText(
      'Tiere',
      'Welches hüpfende Tier trägt sein Junges im Beutel?',
      'KÄNGURU',
      'Kängurus sind Beuteltiere; das Junge heißt Joey.',
    ),
    28: LevelText(
      'Essen',
      'Welches grüne Gemüse sieht aus wie kleine Bäume?',
      'BROKKOLI',
      'Brokkoli gehört zur Familie der Kohlgewächse.',
    ),
    29: LevelText(
      'Natur',
      'Wie nennt man eine riesige, langsam fließende Eismasse?',
      'GLETSCHER',
      'Gletscher entstehen, wo mehr Schnee fällt als schmilzt.',
    ),
    30: LevelText(
      'Geografie',
      'Welche größte heiße Wüste liegt in Nordafrika?',
      'SAHARA',
      'Die Sahara bedeckt weite Teile Nordafrikas.',
    ),
  };

  // ---- Swedish --------------------------------------------------------------
  static const Map<int, LevelText> _sv = {
    1: LevelText(
      'Djur',
      'Vilket djur bygger dammar av grenar och lera?',
      'BÄVER',
      'Bävrar bygger dammar av grenar, lera och stenar.',
    ),
    2: LevelText(
      'Mat',
      'Vilken lång, gul, böjd frukt äter apor gärna?',
      'BANAN',
      'Bananer växer i klasar och är rika på kalium.',
    ),
    3: LevelText(
      'Natur',
      'Vilken färgglad båge syns efter regn och sol?',
      'REGNBÅGE',
      'En regnbåge bildas när ljus bryts i regndroppar.',
    ),
    4: LevelText(
      'Vardag',
      'Vad öppnar du för att hålla dig torr i regnet?',
      'PARAPLY',
      'Ett paraply spänner en duk över spröt.',
    ),
    5: LevelText(
      'Djur',
      'Vilken flygoförmögen svartvit fågel vaggar över isen?',
      'PINGVIN',
      'Pingviner kan inte flyga men simmar mycket bra.',
    ),
    6: LevelText(
      'Geografi',
      'Vilket land har de stora pyramiderna och Nilen?',
      'EGYPTEN',
      'Egypten ligger i Nordafrika vid floden Nilen.',
    ),
    7: LevelText(
      'Vetenskap',
      'Vilken osynlig kraft drar ett äpple mot marken?',
      'GRAVITATION',
      'Gravitationen drar massor mot varandra.',
    ),
    8: LevelText(
      'Sport',
      'I vilken racketsport slår man en boll över ett nät?',
      'TENNIS',
      'Tennis spelas med racket och boll över ett nät.',
    ),
    9: LevelText(
      'Djur',
      'Vilket havsdjur har åtta armar med sugkoppar?',
      'BLÄCKFISK',
      'En bläckfisk har åtta armar och är mycket smart.',
    ),
    10: LevelText(
      'Mat',
      'Vilken platt, rund frukost steks i en panna?',
      'PANNKAKA',
      'Pannkakor görs av mjöl, ägg och mjölk.',
    ),
    11: LevelText(
      'Natur',
      'Vilket berg kan få utbrott och spy lava?',
      'VULKAN',
      'En vulkan är en öppning där magma når ytan.',
    ),
    12: LevelText(
      'Teknik',
      'Vad skriver du bokstäver med på datorn?',
      'TANGENTBORD',
      'Ett tangentbord gör tangenttryck till tecken.',
    ),
    13: LevelText(
      'Djur',
      'Vilket smart havsdäggdjur klickar och hoppar ur vattnet?',
      'DELFIN',
      'Delfiner navigerar med klickljud.',
    ),
    14: LevelText(
      'Vardag',
      'Vilket verktyg med två blad klipper papper?',
      'SAX',
      'En sax klipper med två rörliga blad.',
    ),
    15: LevelText(
      'Geografi',
      'Vilket nordligt land har ett rött lönnlöv på flaggan?',
      'KANADA',
      'Kanada är världens näst största land.',
    ),
    16: LevelText(
      'Vetenskap',
      'Vilken gas i luften behöver vi för att andas?',
      'SYRE',
      'Syre utgör ungefär 21% av luften.',
    ),
    17: LevelText(
      'Djur',
      'Vilket är det största landdjuret med lång snabel?',
      'ELEFANT',
      'Elefanter greppar mat med snabeln.',
    ),
    18: LevelText(
      'Historia',
      'I vilken befäst byggnad bodde kungar på medeltiden?',
      'SLOTT',
      'Slott och borgar hade tjocka murar och torn.',
    ),
    19: LevelText(
      'Natur',
      'Vilket mullrande ljud följer på en blixt?',
      'ÅSKA',
      'Åska är ljudet av luft som hettas upp runt en blixt.',
    ),
    20: LevelText(
      'Teknik',
      'Vilket världsomspännande nät kopplar samman datorer?',
      'INTERNET',
      'Internet kopplar samman miljarder enheter.',
    ),
    21: LevelText(
      'Djur',
      'Vilket fläckigt kattdjur är den snabbaste löparen på land?',
      'GEPARD',
      'En gepard springer korta stunder i 100 km/h.',
    ),
    22: LevelText(
      'Mat',
      'Vilken krämig grön frukt mosas till guacamole?',
      'AVOKADO',
      'Avokado är rik på nyttiga fetter.',
    ),
    23: LevelText(
      'Geografi',
      'Vad heter jordens högsta berg?',
      'EVEREST',
      'Mount Everest är cirka 8 849 meter högt.',
    ),
    24: LevelText(
      'Vetenskap',
      'Vad drar till sig järn och har nord- och sydpol?',
      'MAGNET',
      'Magneter är starkast vid sina två poler.',
    ),
    25: LevelText(
      'Sport',
      'Vilket långdistanslopp är ungefär 42 kilometer?',
      'MARATHON',
      'Maraton är uppkallat efter en ort i antikens Grekland.',
    ),
    26: LevelText(
      'Vardag',
      'Vilket instrument har en nål som pekar mot norr?',
      'KOMPASS',
      'Kompassnålen ställer in sig efter jordens magnetfält.',
    ),
    27: LevelText(
      'Djur',
      'Vilket hoppande djur bär sin unge i en pung?',
      'KÄNGURU',
      'Känguruer är pungdjur; ungen kallas joey.',
    ),
    28: LevelText(
      'Mat',
      'Vilken grön grönsak ser ut som små träd?',
      'BROCCOLI',
      'Broccoli tillhör kålfamiljen.',
    ),
    29: LevelText(
      'Natur',
      'Vad kallas en enorm, långsamt rörlig ismassa?',
      'GLACIÄR',
      'Glaciärer bildas där mer snö faller än vad som smälter.',
    ),
    30: LevelText(
      'Geografi',
      'Vilken största varma öken ligger i Nordafrika?',
      'SAHARA',
      'Sahara täcker stora delar av Nordafrika.',
    ),
  };

  // ---- Finnish --------------------------------------------------------------
  static const Map<int, LevelText> _fi = {
    1: LevelText(
      'Eläimet',
      'Mikä eläin rakentaa patoja oksista ja mudasta?',
      'MAJAVA',
      'Majavat rakentavat patoja oksista, mudasta ja kivistä.',
    ),
    2: LevelText(
      'Ruoka',
      'Mikä pitkä, keltainen, kaareva hedelmä maistuu apinoille?',
      'BANAANI',
      'Banaanit kasvavat tertuissa ja sisältävät kaliumia.',
    ),
    3: LevelText(
      'Luonto',
      'Mikä värikäs kaari ilmestyy taivaalle sateen ja auringon jälkeen?',
      'SATEENKAARI',
      'Sateenkaari syntyy, kun valo taittuu sadepisaroissa.',
    ),
    4: LevelText(
      'Arki',
      'Minkä avaat pysyäksesi kuivana sateessa?',
      'SATEENVARJO',
      'Sateenvarjossa on kangas kaarien päällä.',
    ),
    5: LevelText(
      'Eläimet',
      'Mikä lentokyvytön mustavalkoinen lintu tallustaa jäällä?',
      'PINGVIINI',
      'Pingviinit eivät osaa lentää mutta uivat hyvin.',
    ),
    6: LevelText(
      'Maantiede',
      'Missä maassa ovat suuret pyramidit ja Niili?',
      'EGYPTI',
      'Egypti sijaitsee Pohjois-Afrikassa Niilin varrella.',
    ),
    7: LevelText(
      'Tiede',
      'Mikä näkymätön voima vetää omenan maahan?',
      'PAINOVOIMA',
      'Painovoima vetää massoja toisiaan kohti.',
    ),
    8: LevelText(
      'Urheilu',
      'Missä mailapelissä lyödään palloa verkon yli?',
      'TENNIS',
      'Tennistä pelataan mailalla ja pallolla verkon yli.',
    ),
    9: LevelText(
      'Eläimet',
      'Millä merieläimellä on kahdeksan imukuppista lonkeroa?',
      'MUSTEKALA',
      'Mustekalalla on kahdeksan lonkeroa ja se on älykäs.',
    ),
    10: LevelText(
      'Ruoka',
      'Mikä litteä, pyöreä aamiainen paistetaan pannulla?',
      'PANNUKAKKU',
      'Pannukakku tehdään jauhoista, kananmunasta ja maidosta.',
    ),
    11: LevelText(
      'Luonto',
      'Mikä vuori voi purkautua ja syöstä laavaa?',
      'TULIVUORI',
      'Tulivuori on aukko, josta magma pääsee pintaan.',
    ),
    12: LevelText(
      'Teknologia',
      'Millä kirjoitat kirjaimia tietokoneelle?',
      'NÄPPÄIMISTÖ',
      'Näppäimistö muuttaa painallukset merkeiksi.',
    ),
    13: LevelText(
      'Eläimet',
      'Mikä älykäs merinisäkäs naksuttaa ja hyppii vedestä?',
      'DELFIINI',
      'Delfiinit suunnistavat naksahduksilla.',
    ),
    14: LevelText(
      'Arki',
      'Mikä kaksiteräinen työkalu leikkaa paperia?',
      'SAKSET',
      'Sakset leikkaavat kahdella liikkuvalla terällä.',
    ),
    15: LevelText(
      'Maantiede',
      'Minkä pohjoisen maan lipussa on punainen vaahteranlehti?',
      'KANADA',
      'Kanada on maailman toiseksi suurin maa.',
    ),
    16: LevelText(
      'Tiede',
      'Mitä kaasua tarvitsemme ilmasta hengittääksemme?',
      'HAPPI',
      'Happea on ilmasta noin 21 prosenttia.',
    ),
    17: LevelText(
      'Eläimet',
      'Mikä on suurin maaeläin, jolla on pitkä kärsä?',
      'NORSU',
      'Norsu tarttuu ruokaan pitkällä kärsällään.',
    ),
    18: LevelText(
      'Historia',
      'Millaisessa linnoitetussa rakennuksessa kuninkaat asuivat?',
      'LINNA',
      'Linnoissa oli paksut muurit ja tornit suojana.',
    ),
    19: LevelText(
      'Luonto',
      'Mikä jyrisevä ääni seuraa salamaa?',
      'UKKONEN',
      'Ukkonen on salaman ympärillä laajenevan ilman ääni.',
    ),
    20: LevelText(
      'Teknologia',
      'Mikä maailmanlaajuinen verkko yhdistää tietokoneet?',
      'INTERNET',
      'Internet yhdistää miljardeja laitteita.',
    ),
    21: LevelText(
      'Eläimet',
      'Mikä täplikäs suurkissa on nopein juoksija maalla?',
      'GEPARDI',
      'Gepardi juoksee hetken jopa 100 km/h.',
    ),
    22: LevelText(
      'Ruoka',
      'Mikä kermainen vihreä hedelmä soseutetaan guacamoleksi?',
      'AVOKADO',
      'Avokado sisältää terveellisiä rasvoja.',
    ),
    23: LevelText(
      'Maantiede',
      'Mikä on maailman korkein vuori?',
      'EVEREST',
      'Mount Everest on noin 8 849 metriä korkea.',
    ),
    24: LevelText(
      'Tiede',
      'Mikä vetää puoleensa rautaa ja jolla on kaksi napaa?',
      'MAGNEETTI',
      'Magneetti on voimakkain kahdesta navastaan.',
    ),
    25: LevelText(
      'Urheilu',
      'Mikä pitkän matkan juoksu on noin 42 kilometriä?',
      'MARATON',
      'Maraton on nimetty muinaisen Kreikan paikan mukaan.',
    ),
    26: LevelText(
      'Arki',
      'Missä välineessä neula osoittaa aina pohjoiseen?',
      'KOMPASSI',
      'Kompassineula asettuu Maan magneettikentän mukaan.',
    ),
    27: LevelText(
      'Eläimet',
      'Mikä hyppivä eläin kantaa poikastaan pussissa?',
      'KENGURU',
      'Kengurut ovat pussieläimiä; poikanen on joey.',
    ),
    28: LevelText(
      'Ruoka',
      'Mikä vihreä vihannes näyttää pieniltä puilta?',
      'PARSAKAALI',
      'Parsakaali kuuluu kaaliperheeseen.',
    ),
    29: LevelText(
      'Luonto',
      'Mikä on valtava, hitaasti liikkuva jäämassa?',
      'JÄÄTIKKÖ',
      'Jäätiköt syntyvät, missä lunta sataa enemmän kuin sulaa.',
    ),
    30: LevelText(
      'Maantiede',
      'Mikä suurin kuuma aavikko on Pohjois-Afrikassa?',
      'SAHARA',
      'Sahara peittää suuren osan Pohjois-Afrikkaa.',
    ),
  };
}
