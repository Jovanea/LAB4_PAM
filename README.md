# Lab 4 PAM — Online Course App (REST API + Clean Architecture)

Aplicația are același design ca la Lab 2 (varianta 4 din Figma: „Home-1” și
„Course - Overview -1”). Diferența: toate datele vin acum de la un serviciu Web
REST, prin HTTP, în format JSON.

| Ecran | Cerere | Ce date aduce |
|---|---|---|
| Home | `GET https://test-api-jlbn.onrender.com/lab2026/v4/feed` | salutul, avatarul, „Learned today”, caseta „What do you want to learn today?”, „Learning Plan”, „Meetup” |
| Course Overview | `GET https://test-api-jlbn.onrender.com/lab2026/v4/feed/details` | poza cursului, „SPOKEN ENGLISH”, 75 videos / 35 class, titlul, durata, nota, tab-urile, lecțiile, „Free”, „Enroll Now” |

Au rămas în proiect doar fonturile, iconițele Material și ilustrația din a doua
casetă a slider-ului. Pentru ilustrație API-ul nu trimite date, iar iconițele
din API sunt fișiere SVG, care ar cere încă un pachet.

## Funcționalități

- Cereri HTTP asincrone (`http.get` + `async` / `await`), cu limită de 60 de secunde.
- JSON: deserializare (`fromJson`) și serializare (`toJson`) în modelele din `data/models/`.
- Trei stări pe fiecare ecran:
  - **Loading**: „scheletul” paginii (blocuri gri în locul conținutului);
  - **Loaded**: pagina cu datele de la server;
  - **Error**: mesaj clar + butonul „Try again”.
- Pe Home: „trage în jos” reîncarcă datele.
- Lecțiile blocate (`locked: true` în JSON) au lacăt și nu se pot apăsa.
- Descrierea goală din API afișează „No description for this course yet.”.

## Structura (Clean Architecture)

```
lib/
  main.dart                         – leagă straturile între ele și pornește aplicația
  domain/                           – CE face aplicația (fără Flutter, fără HTTP, fără JSON)
    entities/home_feed.dart         – HomeFeed, PlanItem
    entities/course_details.dart    – CourseDetails, Lesson
    repositories/course_repository.dart – contractul (interfața) pentru date
    usecases/get_home_feed.dart     – cazul de utilizare „pagina principală”
    usecases/get_course_details.dart – cazul de utilizare „detaliile cursului”
    failure.dart                    – eroarea cu mesaj pentru utilizator
  data/                             – DE UNDE vin datele
    datasources/course_api.dart     – cererile HTTP GET și decodarea JSON
    models/home_feed_model.dart     – HomeFeed + fromJson / toJson
    models/course_details_model.dart – CourseDetails + fromJson / toJson
    repositories/course_repository_impl.dart – implementează contractul, traduce erorile
  presentation/                     – CE vede utilizatorul
    cubit/home_cubit.dart           – stările și logica ecranului Home
    cubit/course_cubit.dart         – stările și logica ecranului Course Overview
    screens/                        – cele două ecrane
    widgets/                        – componente reutilizabile: NetImage, SkeletonBox,
                                      ErrorView, LearnedTodayCard, AdsCard,
                                      LearningPlanCard, MeetupCard, LessonRow
    theme/app_style.dart            – culorile și umbrele din Figma
test/
  data_test.dart                    – JSON-ul real, serializarea, erorile HTTP
  cubit_test.dart                   – stările Loading / Loaded / Error
  widget_test.dart                  – ecranele, navigarea, „Try again”
  fixtures/                         – răspunsurile reale ale serverului (pentru teste)
```

**Regula dependențelor:** Presentation → Domain ← Data.
- Domain nu importă nimic din celelalte două straturi.
- Ecranele nu știu că există HTTP sau JSON.
- Stratul Data nu știe că există ecrane.

## Fluxul datelor (de explicat la prezentare)

Exemplu: utilizatorul deschide aplicația.

```
 HomeScreen ──(1) load()──▶ HomeCubit ──(2)──▶ GetHomeFeed ──(3)──▶ CourseRepository
     ▲                         │                                   (contract, Domain)
     │                         │                                        │
     │ (8) BlocBuilder         │ (7) emit(HomeLoaded(feed))             ▼
     │     redesenează         │     sau emit(HomeError(mesaj))  CourseRepositoryImpl (Data)
     └──────── starea ◀────────┘                                        │ (4)
                                                                        ▼
                         (6) HomeFeedModel.fromJson(Map) ◀──── CourseApi ──(5) GET /feed──▶ server
                                                                        ◀── 200 + JSON ───
```

1. **Pornirea.** `main()` creează `CourseApi(http.Client())`, apoi
   `CourseRepositoryImpl`. `BlocProvider` creează `HomeCubit` și apelează imediat
   `load()`.
2. **Starea Loading.** Cubit-ul emite `HomeLoading()`, iar `BlocBuilder`
   desenează scheletul paginii.
3. **Domain.** Cubit-ul apelează cazul de utilizare `GetHomeFeed()`. Acesta cere
   datele de la `CourseRepository`, care e doar un contract (o interfață).
4. **Data.** Implementarea reală a contractului este `CourseRepositoryImpl`. Ea
   apelează `CourseApi.getHomeFeed()`.
5. **HTTP.** `CourseApi` trimite cererea `GET .../feed` cu `await`. Aplicația nu
   se blochează cât așteaptă: e o operație asincronă (`Future`).
6. **JSON → obiect.** Serverul răspunde cu codul 200 și un text JSON.
   - `jsonDecode` transformă textul în `Map<String, dynamic>`.
   - `HomeFeedModel.fromJson` transformă `Map`-ul într-un obiect Dart. Asta e
     deserializarea.
   - Modelul extinde entitatea `HomeFeed`, deci mai departe circulă ca entitate.
7. **Înapoi la Cubit.** Cubit-ul primește `HomeFeed` și emite `HomeLoaded(feed)`.
8. **Redesenarea.** `BlocBuilder` redesenează ecranul. Widget-urile primesc
   textele și adresele pozelor, iar `NetImage` descarcă pozele.

**Când apare o eroare** (fără internet, server picat, JSON greșit):
- `CourseApi` aruncă o excepție tehnică: `ClientException`, `TimeoutException`,
  `ServerException` sau `FormatException`.
- `CourseRepositoryImpl` o transformă într-un `Failure`, cu un mesaj pe înțelesul
  utilizatorului.
- Cubit-ul emite `HomeError(mesaj)`, iar ecranul arată `ErrorView`.
- „Try again” apelează din nou `load()` și drumul se reia de la pasul 2.

**Ecranul 2.** La „Get Started” (sau la orice card), Home deschide
`CourseOverviewScreen.route(...)`. Ruta creează un `CourseCubit` nou, care face
același drum prin `GetCourseDetails` spre `GET .../feed/details`.

## Întrebări posibile la prezentare

- **De ce trei straturi?** Fiecare are o singură grijă.
  - Dacă se schimbă serverul, modifici doar `data/`.
  - Dacă se schimbă designul, modifici doar `presentation/`.
  - Logica din `domain/` nu depinde de niciunul.
- **Ce face un use case?** Dă un nume unei acțiuni a utilizatorului („afișează
  pagina principală”). Cubit-ul cheamă acțiunea, nu știe de unde vin datele.
- **De ce repository-ul e abstract în Domain?** Ca Domain să nu depindă de HTTP.
  În teste se pune un server fals (`MockClient`), iar aplicația merge la fel.
- **Unde e serializarea?** În `toJson()` din modele (obiect → `Map` → text, cu
  `jsonEncode`). Testul `data_test.dart` verifică dacă `fromJson(toJson(x))` dă
  aceleași date.
- **De ce Cubit și nu `setState`?** Datele și logica de încărcare stau în afara
  ecranului. Ecranul doar desenează starea. `setState` a rămas doar pentru lucruri
  de interfață: tab-ul activ, pagina din slider.
- **De ce `if (!isClosed)` în Cubit?** Utilizatorul poate închide ecranul înainte
  să vină răspunsul. Un Cubit închis nu mai are voie să emită stări.
- **De ce limita de 60 de secunde?** Serverul gratuit (Render) „doarme”, iar la
  prima cerere pornește în 30-50 de secunde.
- **De ce `utf8.decode(response.bodyBytes)`?** Ca apostroful din „Let’s” să nu
  apară stricat.
- **Permisiunea de internet** e în `android/app/src/main/AndroidManifest.xml`
  (`android.permission.INTERNET`). Fără ea, versiunea release nu poate face cereri.

## Rulare

```bash
flutter pub get
flutter run          # pe emulator sau telefon (are nevoie de internet)
flutter test         # 16 teste, merg fără internet
flutter analyze
```
