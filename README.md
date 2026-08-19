# System Automatyzacji Pomiarów Czasu - Las Odkrywców

System składa się z dwóch komponentów:
1. **Backend**: Spring Boot 3 z bazą PostgreSQL (konfiguracja Dockerowa).
2. **Frontend**: Aplikacja Android napisana we Flutterze, z automatycznym systemem Background Geofencing.

## Zanim zaczniesz...
Aplikacja została przystosowana do pracy w architekturze "Offline-First". Pracownicy logują się do systemu (wymagane jedno wejście z zasięgiem Wi-Fi w celu pobrania początkowej bazy Atrakcji i uwierzytelnienia JWT). Gdy znajdą się w lesie i wejdą w promień + 5 metrów od punktu atrakcji, ich telefony automatycznie rozpoczną pomiar i zapiszą do lokalnej bazy danych Drift. 

Synchronizacja może nastąpić później, na ekranie głównym aplikacji za pomocą przycisku synchronizacji (chmura).

---

## 🛠️ 1. Uruchomienie lokalne (Programista / Testy na Emulatorze)

Jeżeli chcesz testować system na swoim lokalnym komputerze:

1. W pliku `Flutter app\lib\api\api_client.dart` upewnij się, że masz ustawiony adres emulatora Androida:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8080/api';
   ```
2. Odpal serwer Backendowy (z wbudowaną testową bazą H2):
   ```bash
   cd backend
   .\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=test"
   ```
3. Zbuduj aplikację Flutter:
   ```bash
   cd "Flutter app"
   flutter run
   ```
4. Zaloguj się wirtualnym kontem w emulatorze:
   - **Login**: `admin`
   - **Hasło**: `admin`

*Konto to posiada specjalne uprawnienia Administratora, otwierając ukryte zakładki panelu GPS.*

---

---

## 🌲 2. Wdrożenie Serwera w Lesie (IP: 192.168.151.13)

Gdy środowisko w lesie jest gotowe (postawiona Maszyna Wirtualna, działa lokalne WiFi):

### Wymagania serwerowe:
- System operacyjny: Ubuntu / Debian (zalecane) lub Windows
- Zainstalowany **Git**
- Zainstalowany **Docker** oraz wtyczka **Docker Compose**

### Instrukcja Krok po Kroku (na serwerze):
1. **Otwórz terminal/konsolę** maszyny wirtualnej.
2. **Pobierz najnowszy kod aplikacji**:
   ```bash
   git clone [TWOJ_LINK_GITHUB]
   cd Atrakcje_las/backend
   ```
   *(Jeśli już to robiłeś, wpisz po prostu `git pull origin main` będąc w tym folderze).*
3. **Uruchom serwer i bazę danych**:
   ```bash
   docker-compose up -d --build
   ```
   Ta flaga `-d` uruchomi wszystko w tle. Flaga `--build` wymusi przebudowanie Javy na najnowszą wersję.
4. **Weryfikacja**:
   By upewnić się, że Spring Boot połączył się z bazą danych wpisz:
   ```bash
   docker-compose logs -f backend
   ```
   Gdy zobaczysz `Started TimeappApplication in ... seconds`, to znaczy, że serwer działa na IP `192.168.151.13:8080`.

---

## 📱 3. Instalacja aplikacji na telefonach Android

Android pozwala na bezpośrednią instalację (Sideloading) z pliku pobranego poza oficjalnym sklepem Google Play.

### Na komputerze programisty:
1. Upewnij się, że w pliku `Flutter app/lib/api/api_client.dart` jest adres:
   `static const String baseUrl = 'http://192.168.151.13:8080/api';`
2. Zbuduj wersję produkcyjną aplikacji:
   ```bash
   cd "Flutter app"
   flutter clean
   flutter build apk --release
   ```
3. Zlokalizuj plik `app-release.apk` w folderze:
   `Flutter app\build\app\outputs\flutter-apk\app-release.apk`

### Na urządzeniach pracowników (Android):
1. Prześlij ten plik na telefony (przez Dysk Google, e-mail, kabel USB lub udostępnij na lokalnym serwerze).
2. Pracownik wchodzi w pobrany plik. Android poprosi o pozwolenie na **"Zainstalowanie z nieznanego źródła"** - należy wejść w ustawienia i wyrazić zgodę (Zezwalaj z tego źródła).
3. Zainstaluj i otwórz aplikację "Czas Pracy".
4. Nadaj wymagane uprawnienia do GPS (**"Zezwól zawsze"** lub "Podczas używania aplikacji", zależnie co zasugeruje Android). Zezwól na powiadomienia, jeśli aplikacja o to poprosi.

---

## 🍏 4. Instalacja aplikacji na urządzeniach iPhone (iOS)

Wdrażanie aplikacji na iOS jest bardziej restrykcyjne przez zasady firmy Apple i **wymaga użycia komputera z systemem macOS (np. MacBook)**.

### Krok 1: Wymagania
1. **MacBook / Mac** (kompilacja nie jest możliwa pod systemem Windows).
2. Zainstalowany program **Xcode** (darmowy ze sklepu App Store na Macu).
3. Płatne konto **Apple Developer Account** (ok. 99$ rocznie), by zainstalować aplikację na wielu urządzeniach bez ograniczeń czasowych (tzw. Apple Enterprise lub przez TestFlight).

### Krok 2: Przygotowanie i kompilacja (Na MacBooku)
1. Zgraj kod projektu na Maca (przez GitHuba).
2. Ustaw `baseUrl` tak samo jak wyżej.
3. Otwórz terminal i wejdź do folderu `Flutter app`.
4. Zainstaluj zależności systemu iOS:
   ```bash
   flutter pub get
   cd ios
   pod install
   ```
5. Otwórz projekt w Xcode:
   ```bash
   open Runner.xcworkspace
   ```

### Krok 3: Podpisanie aplikacji i dystrybucja
1. W programie **Xcode**, kliknij na główny folder projektu **Runner**.
2. W zakładce **Signing & Capabilities** wybierz swoje konto Apple Developer w polu "Team".
3. Określ swój unikalny Bundle Identifier (np. `com.las.odkrywcow`).
4. Upewnij się, że w pliku `Info.plist` znajduje się pozwolenie na użycie lokalizacji (dodano wcześniej podczas konfiguracji).
5. **Dystrybucja TestFlight (Zalecane dla pracowników)**:
   - W górnym menu Xcode wybierz *Product > Archive*.
   - Po zbudowaniu archiwum kliknij *Distribute App* i wyślij na serwery App Store Connect.
   - Dodaj adresy email iCloud swoich pracowników w konsoli Apple. Na swoich iPhone'ach pracownicy pobiorą darmową aplikację **TestFlight**, z której automatycznie pobiorą Twoją leśną aplikację wprost na pulpit.
