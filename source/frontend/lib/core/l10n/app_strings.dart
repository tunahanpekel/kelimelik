// lib/core/l10n/app_strings.dart
//
// Kelimelik — lightweight localization, no codegen required.
//
// Usage:
//   S.of(context).someKey
//   ref.watch(localeProvider)  ← required in every ConsumerWidget that shows text
//
// Supported: tr, en, es, de, fr, pt

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Locale Provider ──────────────────────────────────────────────────────────

const _kLangKey = 'app_language';
const _supportedLangs = ['tr', 'en', 'es', 'de', 'fr', 'pt'];

String _deviceLang() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return _supportedLangs.contains(code) ? code : 'tr'; // Turkish as default
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return Locale(_deviceLang());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);
  }

  bool get isTurkish    => state.languageCode == 'tr';
  bool get isEnglish    => state.languageCode == 'en';
  bool get isSpanish    => state.languageCode == 'es';
  bool get isGerman     => state.languageCode == 'de';
  bool get isFrench     => state.languageCode == 'fr';
  bool get isPortuguese => state.languageCode == 'pt';
}

// ─── String lookup ────────────────────────────────────────────────────────────

class S {
  const S._(this._locale);
  final Locale _locale;
  String get _lang => _locale.languageCode;
  bool get _tr => _lang == 'tr';
  bool get _es => _lang == 'es';
  bool get _de => _lang == 'de';
  bool get _fr => _lang == 'fr';
  bool get _pt => _lang == 'pt';

  static S of(BuildContext context) => S._(Localizations.localeOf(context));

  // ── Common ───────────────────────────────────────────────────────────────────
  String get commonOk           => _tr ? 'Tamam'          : _es ? 'Aceptar'      : _de ? 'OK'              : _fr ? 'OK'             : _pt ? 'OK'              : 'OK';
  String get commonCancel       => _tr ? 'İptal'          : _es ? 'Cancelar'     : _de ? 'Abbrechen'       : _fr ? 'Annuler'        : _pt ? 'Cancelar'        : 'Cancel';
  String get commonContinue     => _tr ? 'Devam Et'       : _es ? 'Continuar'    : _de ? 'Weiter'          : _fr ? 'Continuer'      : _pt ? 'Continuar'       : 'Continue';
  String get commonBack         => _tr ? 'Geri'           : _es ? 'Atrás'        : _de ? 'Zurück'          : _fr ? 'Retour'         : _pt ? 'Voltar'          : 'Back';
  String get commonLoading      => _tr ? 'Yükleniyor...'  : _es ? 'Cargando...'  : _de ? 'Laden...'        : _fr ? 'Chargement...'  : _pt ? 'Carregando...'   : 'Loading...';
  String get commonError        => _tr ? 'Hata'           : _es ? 'Error'        : _de ? 'Fehler'          : _fr ? 'Erreur'         : _pt ? 'Erro'            : 'Error';
  String get commonRetry        => _tr ? 'Tekrar Dene'    : _es ? 'Reintentar'   : _de ? 'Wiederholen'     : _fr ? 'Réessayer'      : _pt ? 'Tentar novamente': 'Try Again';
  String get commonPageNotFound => _tr ? 'Sayfa Bulunamadı': _es ? 'Página no encontrada': _de ? 'Seite nicht gefunden': _fr ? 'Page introuvable': _pt ? 'Página não encontrada': 'Page Not Found';
  String get commonGoHome       => _tr ? 'Ana Sayfaya Dön' : _es ? 'Ir al inicio': _de ? 'Zur Startseite' : _fr ? 'Aller à l\'accueil': _pt ? 'Ir para o início': 'Go Home';
  String get commonPlay         => _tr ? 'Oyna'           : _es ? 'Jugar'        : _de ? 'Spielen'         : _fr ? 'Jouer'          : _pt ? 'Jogar'           : 'Play';
  String get commonShare        => _tr ? 'Paylaş'         : _es ? 'Compartir'    : _de ? 'Teilen'          : _fr ? 'Partager'       : _pt ? 'Compartilhar'    : 'Share';
  String get commonPlayAgain    => _tr ? 'Tekrar Oyna'    : _es ? 'Jugar de nuevo': _de ? 'Nochmal spielen': _fr ? 'Rejouer'        : _pt ? 'Jogar de novo'   : 'Play Again';
  String get commonClose        => _tr ? 'Kapat'          : _es ? 'Cerrar'       : _de ? 'Schließen'       : _fr ? 'Fermer'         : _pt ? 'Fechar'          : 'Close';

  // ── Navigation ───────────────────────────────────────────────────────────────
  String get tabHome        => _tr ? 'Ana Sayfa'  : _es ? 'Inicio'    : _de ? 'Startseite'    : _fr ? 'Accueil'    : _pt ? 'Início'         : 'Home';
  String get tabLeaderboard => _tr ? 'Sıralama'   : _es ? 'Ranking'   : _de ? 'Rangliste'     : _fr ? 'Classement' : _pt ? 'Classificação'  : 'Leaderboard';
  String get tabSettings    => _tr ? 'Ayarlar'    : _es ? 'Ajustes'   : _de ? 'Einstellungen' : _fr ? 'Paramètres' : _pt ? 'Configurações'  : 'Settings';

  // ── App / Home ────────────────────────────────────────────────────────────────
  String get appName            => 'Kelimelik';
  String get homeTagline        => _tr ? 'Türkçenin gizli hazinelerini keşfet' : _es ? 'Descubre los tesoros del turco' : _de ? 'Entdecke die Schätze des Türkischen' : _fr ? 'Découvrez les trésors du turc' : _pt ? 'Descubra os tesouros do turco' : 'Discover the treasures of Turkish';
  String get homeSelectMode     => _tr ? 'Bir mod seç'                         : _es ? 'Selecciona un modo'             : _de ? 'Modus wählen'                        : _fr ? 'Choisir un mode'               : _pt ? 'Selecione um modo'              : 'Select a mode';
  String get homeDailyChallenge => _tr ? 'Günlük Meydan Okuma'                 : _es ? 'Desafío diario'                 : _de ? 'Tägliche Herausforderung'            : _fr ? 'Défi quotidien'                : _pt ? 'Desafio diário'                 : 'Daily Challenge';
  String get homeStreak         => _tr ? 'Gün Serisi'                          : _es ? 'Racha de días'                  : _de ? 'Tagesserie'                          : _fr ? 'Série de jours'               : _pt ? 'Sequência de dias'              : 'Day Streak';

  // ── Game Modes ────────────────────────────────────────────────────────────────
  String get modeWordle         => _tr ? 'Kelime Tahmin'   : _es ? 'Adivina la Palabra' : _de ? 'Wort Raten'     : _fr ? 'Deviner le mot' : _pt ? 'Adivinhe a Palavra'  : 'Word Guess';
  String get modeChain          => _tr ? 'Kelime Zinciri'  : _es ? 'Cadena de Palabras' : _de ? 'Wortkette'      : _fr ? 'Chaîne de mots' : _pt ? 'Cadeia de Palavras'  : 'Word Chain';
  String get modeAnagram        => _tr ? 'Anagram'         : _es ? 'Anagrama'           : _de ? 'Anagramm'       : _fr ? 'Anagramme'      : _pt ? 'Anagrama'            : 'Anagram';
  String get modeSpeed          => _tr ? 'Hızlı Tur'       : _es ? 'Turno Rápido'       : _de ? 'Schnellrunde'   : _fr ? 'Tour Rapide'    : _pt ? 'Rodada Rápida'       : 'Speed Round';
  String get modeCategory       => _tr ? 'Kategori Modu'   : _es ? 'Modo Categoría'     : _de ? 'Kategorie'      : _fr ? 'Catégorie'      : _pt ? 'Modo Categoria'      : 'Category Mode';

  String get modeWordleDesc     => _tr ? '6 tahminde gizli kelimeyi bul'            : _es ? 'Encuentra la palabra en 6 intentos'  : _de ? 'Finde das Wort in 6 Versuchen'          : _fr ? 'Trouvez le mot en 6 essais'         : _pt ? 'Encontre a palavra em 6 tentativas'  : 'Find the hidden word in 6 attempts';
  String get modeChainDesc      => _tr ? 'Son harfle yeni kelime söyle'              : _es ? 'Continúa la cadena con la última letra': _de ? 'Setze die Kette mit dem letzten Buchstaben fort': _fr ? 'Continuez la chaîne avec la dernière lettre': _pt ? 'Continue a cadeia com a última letra' : 'Chain words by the last letter';
  String get modeAnagramDesc    => _tr ? 'Karışık harfleri düzene sok'               : _es ? 'Ordena las letras mezcladas'          : _de ? 'Sortiere die gemischten Buchstaben'     : _fr ? 'Remettez les lettres dans l\'ordre'  : _pt ? 'Organize as letras misturadas'       : 'Unscramble the mixed letters';
  String get modeSpeedDesc      => _tr ? '60 saniyede kaç kelime yazabilirsin?'      : _es ? '¿Cuántas palabras puedes escribir en 60s?': _de ? 'Wie viele Wörter in 60 Sekunden?' : _fr ? 'Combien de mots en 60 secondes?'    : _pt ? 'Quantas palavras em 60 segundos?'    : 'How many words in 60 seconds?';
  String get modeCategoryDesc   => _tr ? 'Kategoriye ait kelimeler yaz'              : _es ? 'Escribe palabras de la categoría'     : _de ? 'Schreibe Wörter der Kategorie'         : _fr ? 'Écrivez des mots de la catégorie'   : _pt ? 'Escreva palavras da categoria'       : 'Name words from the category';

  // ── Wordle ────────────────────────────────────────────────────────────────────
  String get wordleTitle        => modeWordle;
  String get wordleAttempts     => _tr ? 'Tahmin'                           : _es ? 'Intento'                 : _de ? 'Versuch'          : _fr ? 'Essai'              : _pt ? 'Tentativa'               : 'Attempt';
  String get wordleWon          => _tr ? 'Tebrikler! 🎉'                    : _es ? '¡Felicitaciones! 🎉'     : _de ? 'Glückwunsch! 🎉'  : _fr ? 'Félicitations! 🎉'  : _pt ? 'Parabéns! 🎉'            : 'Congratulations! 🎉';
  String get wordleLost         => _tr ? 'Bu sefer olmadı.'                  : _es ? 'Esta vez no fue.'        : _de ? 'Diesmal nicht.'   : _fr ? 'Pas cette fois.'    : _pt ? 'Dessa vez não foi.'       : 'Not this time.';
  String get wordleAnswer       => _tr ? 'Cevap:'                            : _es ? 'Respuesta:'              : _de ? 'Antwort:'         : _fr ? 'Réponse:'           : _pt ? 'Resposta:'                : 'Answer:';
  String get wordleInvalidWord  => _tr ? 'Bu kelime sözlükte yok!'           : _es ? '¡Esta palabra no existe!': _de ? 'Dieses Wort existiert nicht!': _fr ? 'Ce mot n\'existe pas!': _pt ? 'Esta palavra não existe!': 'Word not in dictionary!';
  String get wordleTooShort     => _tr ? 'Kelime çok kısa!'                  : _es ? '¡La palabra es muy corta!': _de ? 'Wort zu kurz!' : _fr ? 'Mot trop court!'     : _pt ? 'Palavra muito curta!'      : 'Word too short!';

  // ── Word Chain ────────────────────────────────────────────────────────────────
  String get chainTitle         => modeChain;
  String get chainStartLetter   => _tr ? 'ile başla'                         : _es ? 'empieza con'             : _de ? 'beginne mit'      : _fr ? 'commence par'       : _pt ? 'começa com'              : 'start with';
  String get chainLength        => _tr ? 'Zincir uzunluğu'                   : _es ? 'Longitud de la cadena'   : _de ? 'Kettenlänge'      : _fr ? 'Longueur de chaîne' : _pt ? 'Comprimento da cadeia'   : 'Chain length';
  String get chainBroken        => _tr ? 'Zincir koptu!'                     : _es ? '¡Cadena rota!'           : _de ? 'Kette unterbrochen!': _fr ? 'Chaîne brisée!'   : _pt ? 'Corrente quebrada!'       : 'Chain broken!';
  String get chainWrongStart    => _tr ? 'Bu harfle başlamıyor!'              : _es ? '¡No empieza con esta letra!': _de ? 'Beginnt nicht mit diesem Buchstaben!': _fr ? 'Ne commence pas par cette lettre!': _pt ? 'Não começa com esta letra!': 'Doesn\'t start with that letter!';
  String get chainAlreadyUsed   => _tr ? 'Bu kelime zaten kullanıldı!'       : _es ? '¡Esta palabra ya fue usada!': _de ? 'Dieses Wort wurde bereits verwendet!': _fr ? 'Ce mot a déjà été utilisé!': _pt ? 'Esta palavra já foi usada!': 'Word already used!';

  // ── Anagram ───────────────────────────────────────────────────────────────────
  String get anagramTitle       => modeAnagram;
  String get anagramShuffle     => _tr ? 'Karıştır'                          : _es ? 'Mezclar'                 : _de ? 'Mischen'          : _fr ? 'Mélanger'           : _pt ? 'Embaralhar'              : 'Shuffle';
  String get anagramHint        => _tr ? 'İpucu'                             : _es ? 'Pista'                   : _de ? 'Hinweis'          : _fr ? 'Indice'             : _pt ? 'Dica'                    : 'Hint';
  String get anagramSolved      => _tr ? 'Çözdün! 🎊'                        : _es ? '¡Resuelto! 🎊'           : _de ? 'Gelöst! 🎊'       : _fr ? 'Résolu! 🎊'         : _pt ? 'Resolvido! 🎊'           : 'Solved! 🎊';
  String get anagramTimeUp      => _tr ? 'Süre doldu!'                       : _es ? '¡Tiempo agotado!'        : _de ? 'Zeit abgelaufen!' : _fr ? 'Temps écoulé!'      : _pt ? 'Tempo esgotado!'          : 'Time\'s up!';

  // ── Speed Round ───────────────────────────────────────────────────────────────
  String get speedTitle         => modeSpeed;
  String get speedWords         => _tr ? 'kelime'                            : _es ? 'palabras'                : _de ? 'Wörter'           : _fr ? 'mots'               : _pt ? 'palavras'                : 'words';
  String get speedGetReady      => _tr ? 'Hazır mısın?'                      : _es ? '¿Estás listo?'           : _de ? 'Bist du bereit?'  : _fr ? 'Es-tu prêt?'        : _pt ? 'Você está pronto?'        : 'Ready?';
  String get speedGo            => _tr ? 'BAŞLA!'                            : _es ? '¡EMPIEZA!'               : _de ? 'LOS!'             : _fr ? 'PARTEZ!'            : _pt ? 'VÁ!'                     : 'GO!';
  String get speedCombo         => _tr ? 'Kombo x'                           : _es ? 'Combo x'                 : _de ? 'Kombo x'          : _fr ? 'Combo x'            : _pt ? 'Combo x'                 : 'Combo x';

  // ── Category ──────────────────────────────────────────────────────────────────
  String get categoryTitle      => modeCategory;
  String get categoryInstruct   => _tr ? 'Bu kategoriye ait kelimeler yaz'   : _es ? 'Escribe palabras de esta categoría': _de ? 'Schreibe Wörter dieser Kategorie': _fr ? 'Écris des mots de cette catégorie': _pt ? 'Escreva palavras desta categoria': 'Write words from this category';
  String get categoryPass       => _tr ? 'Kategoriyi Geç'                    : _es ? 'Pasar categoría'          : _de ? 'Kategorie überspringen': _fr ? 'Passer la catégorie': _pt ? 'Pular categoria'      : 'Skip category';

  // ── TDK Reveal ────────────────────────────────────────────────────────────────
  String get tdkTitle           => _tr ? 'Günün Kelimesi'                    : _es ? 'Palabra del día'          : _de ? 'Wort des Tages'   : _fr ? 'Mot du jour'        : _pt ? 'Palavra do dia'          : 'Word of the Round';
  String get tdkMeaning         => _tr ? 'Anlam'                             : _es ? 'Significado'              : _de ? 'Bedeutung'         : _fr ? 'Signification'      : _pt ? 'Significado'             : 'Meaning';
  String get tdkExample         => _tr ? 'Örnek'                             : _es ? 'Ejemplo'                  : _de ? 'Beispiel'          : _fr ? 'Exemple'            : _pt ? 'Exemplo'                 : 'Example';
  String get tdkNoDefinition    => _tr ? 'Kelime bilgisi şu an yüklenemiyor.': _es ? 'Definición no disponible.': _de ? 'Definition nicht verfügbar.': _fr ? 'Définition non disponible.': _pt ? 'Definição não disponível.': 'Definition unavailable.';
  String get tdkChallenge       => _tr ? 'Arkadaşına Meydan Oku'             : _es ? 'Desafiar a un amigo'      : _de ? 'Freund herausfordern': _fr ? 'Défier un ami'     : _pt ? 'Desafiar um amigo'       : 'Challenge a Friend';

  // ── Result Screen ─────────────────────────────────────────────────────────────
  String get resultScore        => _tr ? 'Puan'                              : _es ? 'Puntuación'               : _de ? 'Punkte'           : _fr ? 'Score'              : _pt ? 'Pontuação'               : 'Score';
  String get resultBestScore    => _tr ? 'En İyi Puan'                       : _es ? 'Mejor puntuación'         : _de ? 'Beste Punktzahl'  : _fr ? 'Meilleur score'     : _pt ? 'Melhor pontuação'        : 'Best Score';
  String get resultNewRecord    => _tr ? 'Yeni Rekor! 🔥'                    : _es ? '¡Nuevo Récord! 🔥'        : _de ? 'Neuer Rekord! 🔥' : _fr ? 'Nouveau Record! 🔥' : _pt ? 'Novo Recorde! 🔥'        : 'New Record! 🔥';
  String get resultShareResult  => _tr ? 'Sonucu Paylaş'                     : _es ? 'Compartir resultado'      : _de ? 'Ergebnis teilen'  : _fr ? 'Partager le résultat': _pt ? 'Compartilhar resultado' : 'Share Result';
  String get resultDuration     => _tr ? 'Süre'                              : _es ? 'Duración'                 : _de ? 'Dauer'             : _fr ? 'Durée'              : _pt ? 'Duração'                 : 'Duration';
  String get resultWhatsapp     => _tr ? 'WhatsApp\'ta Paylaş'               : _es ? 'Compartir en WhatsApp'   : _de ? 'Auf WhatsApp teilen': _fr ? 'Partager sur WhatsApp': _pt ? 'Compartilhar no WhatsApp': 'Share on WhatsApp';
  String get resultGoHome       => _tr ? 'Ana Sayfaya Dön'                   : _es ? 'Volver al inicio'         : _de ? 'Zur Startseite'   : _fr ? 'Retour à l\'accueil': _pt ? 'Voltar ao início'         : 'Go Home';

  // ── Leaderboard ───────────────────────────────────────────────────────────────
  String get leaderboardTitle   => _tr ? 'Haftalık Turnuva'                  : _es ? 'Torneo semanal'           : _de ? 'Wöchentliches Turnier': _fr ? 'Tournoi hebdomadaire': _pt ? 'Torneio semanal'     : 'Weekly Tournament';
  String get leaderboardEmpty   => _tr ? 'Henüz sıralama yok'               : _es ? 'Sin clasificación aún'    : _de ? 'Noch keine Rangliste': _fr ? 'Pas encore de classement': _pt ? 'Ainda sem classificação': 'No rankings yet';
  String get leaderboardEmptySub=> _tr ? 'Bu haftanın ilk skoru sen koy!'   : _es ? '¡Sé el primero esta semana!': _de ? 'Sei der Erste diese Woche!': _fr ? 'Sois le premier cette semaine!': _pt ? 'Seja o primeiro esta semana!': 'Be the first this week!';
  String get leaderboardOffline => _tr ? 'Sıralama şu an yüklenemiyor'      : _es ? 'Clasificación no disponible': _de ? 'Rangliste nicht verfügbar': _fr ? 'Classement indisponible': _pt ? 'Classificação indisponível': 'Leaderboard unavailable';
  String get leaderboardMyRank  => _tr ? 'Benim Sıram'                       : _es ? 'Mi posición'              : _de ? 'Mein Rang'         : _fr ? 'Mon classement'     : _pt ? 'Minha posição'          : 'My Rank';
  String get leaderboardTimeLeft=> _tr ? 'kaldı'                             : _es ? 'restante'                 : _de ? 'verbleibend'       : _fr ? 'restant'            : _pt ? 'restante'               : 'left';
  String get leaderboardDays    => _tr ? 'gün'                               : _es ? 'días'                     : _de ? 'Tage'              : _fr ? 'jours'              : _pt ? 'dias'                   : 'days';
  String get leaderboardGames   => _tr ? 'oyun'                              : _es ? 'juegos'                   : _de ? 'Spiele'            : _fr ? 'jeux'               : _pt ? 'jogos'                  : 'games';
  String get leaderboardPoints  => _tr ? 'puan'                              : _es ? 'puntos'                   : _de ? 'Punkte'            : _fr ? 'points'             : _pt ? 'pontos'                 : 'points';
  String get leaderboardShareCTA=> _tr ? 'Bu Haftayı Paylaş'                 : _es ? 'Compartir esta semana'    : _de ? 'Diese Woche teilen' : _fr ? 'Partager cette semaine': _pt ? 'Compartilhar esta semana': 'Share This Week';
  String get leaderboardSignIn  => _tr ? 'Sıralamalara katılmak için giriş yap': _es ? 'Inicia sesión para participar': _de ? 'Anmelden zum Mitmachen': _fr ? 'Connectez-vous pour participer': _pt ? 'Entre para participar': 'Sign in to join the leaderboard';
  String get leaderboardSignInCta => _tr ? 'Google ile Giriş Yap'            : _es ? 'Entrar con Google'        : _de ? 'Mit Google anmelden': _fr ? 'Connexion Google'   : _pt ? 'Entrar com Google'       : 'Sign in with Google';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  String get authSignInGoogle   => _tr ? 'Google ile Devam Et'               : _es ? 'Continuar con Google'    : _de ? 'Mit Google fortfahren': _fr ? 'Continuer avec Google': _pt ? 'Continuar com Google' : 'Continue with Google';
  String get authPlayAsGuest    => _tr ? 'Misafir olarak oyna'               : _es ? 'Jugar como invitado'      : _de ? 'Als Gast spielen'  : _fr ? 'Jouer en tant qu\'invité': _pt ? 'Jogar como convidado': 'Play as guest';
  String get authSignOut        => _tr ? 'Çıkış Yap'                         : _es ? 'Cerrar sesión'            : _de ? 'Abmelden'          : _fr ? 'Se déconnecter'     : _pt ? 'Sair'                    : 'Sign Out';
  String get authSignIn         => _tr ? 'Giriş Yap'                         : _es ? 'Iniciar sesión'           : _de ? 'Anmelden'          : _fr ? 'Se connecter'       : _pt ? 'Entrar'                  : 'Sign In';

  // ── Onboarding ────────────────────────────────────────────────────────────────
  String get onboardingGetStarted    => _tr ? 'Oynamaya Başla'               : _es ? 'Empezar a jugar'          : _de ? 'Spielen starten'  : _fr ? 'Commencer à jouer'  : _pt ? 'Começar a jogar'         : 'Start Playing';
  String get onboardingSkip          => _tr ? 'Geç'                          : _es ? 'Omitir'                   : _de ? 'Überspringen'     : _fr ? 'Passer'             : _pt ? 'Pular'                   : 'Skip';
  String get onboarding1Title        => _tr ? 'Türkçenin gizli hazinelerini keşfet': _es ? 'Descubre los tesoros del turco': _de ? 'Entdecke die Schätze des Türkischen': _fr ? 'Découvrez les trésors du turc': _pt ? 'Descubra os tesouros do turco': 'Discover the hidden treasures of Turkish';
  String get onboarding1Subtitle     => _tr ? '5 farklı oyun modu, sonsuz kelime eğlencesi.': _es ? '5 modos de juego, diversión infinita con palabras.': _de ? '5 Spielmodi, endloser Wortspaß.': _fr ? '5 modes de jeu, plaisir infini avec les mots.': _pt ? '5 modos de jogo, diversão infinita com palavras.': '5 game modes, endless word fun.';
  String get onboarding2Title        => _tr ? 'Bil, zincirle, çöz, yarış'   : _es ? 'Adivina, encadena, resuelve, compite': _de ? 'Erraten, verketten, lösen, konkurrieren': _fr ? 'Deviner, enchaîner, résoudre, concourir': _pt ? 'Adivinhe, encadeie, resolva, compita': 'Guess, chain, solve, compete';
  String get onboarding2Subtitle     => _tr ? 'Her modda farklı bir meydan okuma. TDK sözlüğünden gerçek kelimeler.': _es ? 'Un desafío diferente en cada modo. Palabras reales del diccionario turco.': _de ? 'Jeder Modus ist eine andere Herausforderung.': _fr ? 'Un défi différent pour chaque mode.': _pt ? 'Um desafio diferente em cada modo.': 'A different challenge in every mode. Real words from the Turkish dictionary.';
  String get onboarding3Title        => _tr ? 'Haftalık turnuvaya katıl'     : _es ? 'Únete al torneo semanal'   : _de ? 'Am Wochenturnier teilnehmen': _fr ? 'Rejoindre le tournoi hebdomadaire': _pt ? 'Participe do torneio semanal': 'Join the weekly tournament';
  String get onboarding3Subtitle     => _tr ? 'Arkadaşlarınla yarış, liderlik tablosuna çık.': _es ? 'Compite con amigos, sube al ranking.': _de ? 'Konkurriere mit Freunden, klettere in der Rangliste.': _fr ? 'Affronte tes amis, monte dans le classement.': _pt ? 'Compita com amigos, suba no ranking.': 'Compete with friends, climb the leaderboard.';

  // ── Settings ──────────────────────────────────────────────────────────────────
  String get settingsLanguage        => _tr ? 'Dil'            : _es ? 'Idioma'       : _de ? 'Sprache'     : _fr ? 'Langue'     : _pt ? 'Idioma'     : 'Language';
  String get settingsAccount         => _tr ? 'Hesap'          : _es ? 'Cuenta'       : _de ? 'Konto'       : _fr ? 'Compte'     : _pt ? 'Conta'      : 'Account';
  String get settingsPrivacy         => _tr ? 'Gizlilik Politikası': _es ? 'Política de privacidad': _de ? 'Datenschutzrichtlinie': _fr ? 'Politique de confidentialité': _pt ? 'Política de privacidade': 'Privacy Policy';
  String get settingsTerms           => _tr ? 'Kullanım Koşulları': _es ? 'Términos de uso': _de ? 'Nutzungsbedingungen': _fr ? 'Conditions d\'utilisation': _pt ? 'Termos de uso': 'Terms of Use';
  String get settingsDeleteAccount   => _tr ? 'Hesabı Sil'     : _es ? 'Eliminar cuenta': _de ? 'Konto löschen': _fr ? 'Supprimer le compte': _pt ? 'Excluir conta': 'Delete Account';
  String get settingsDeleteAccountWarning => _tr ? 'Bu işlem geri alınamaz.' : _es ? 'Esta acción no se puede deshacer.' : _de ? 'Diese Aktion kann nicht rückgängig gemacht werden.' : _fr ? 'Cette action est irréversible.' : _pt ? 'Esta ação não pode ser desfeita.' : 'This action cannot be undone.';
  String get settingsStats           => _tr ? 'İstatistikler'  : _es ? 'Estadísticas' : _de ? 'Statistiken' : _fr ? 'Statistiques': _pt ? 'Estatísticas': 'Statistics';
  String get settingsLegal           => _tr ? 'Hesap ve Hukuki': _es ? 'Cuenta y legal': _de ? 'Konto & Rechtliches': _fr ? 'Compte & Légal': _pt ? 'Conta e jurídico': 'Account & Legal';
  String get settingsTotalGames      => _tr ? 'Toplam Oyun'    : _es ? 'Juegos totales': _de ? 'Spiele gesamt': _fr ? 'Jeux au total': _pt ? 'Total de jogos': 'Total Games';
  String get settingsWinRate         => _tr ? 'Kazanma Oranı'  : _es ? 'Tasa de victorias': _de ? 'Gewinnrate': _fr ? 'Taux de victoire': _pt ? 'Taxa de vitórias': 'Win Rate';
  String get settingsBestStreak      => _tr ? 'En İyi Seri'    : _es ? 'Mejor racha'  : _de ? 'Beste Serie' : _fr ? 'Meilleure série': _pt ? 'Melhor sequência': 'Best Streak';

  // ── Errors ────────────────────────────────────────────────────────────────────
  String get errorNetwork       => _tr ? 'Bağlantı sorunu. İnternet bağlantını kontrol et.'  : _es ? 'Problema de conexión. Verifica tu internet.' : _de ? 'Verbindungsproblem. Überprüfe deine Internetverbindung.' : _fr ? 'Problème de connexion. Vérifiez votre connexion.' : _pt ? 'Problema de conexão. Verifique sua internet.' : 'Connection problem. Check your internet.';
  String get errorGeneric       => _tr ? 'Bir şeyler ters gitti. Tekrar dene!'               : _es ? 'Algo salió mal. ¡Inténtalo de nuevo!'      : _de ? 'Etwas ist schiefgelaufen. Versuche es erneut!'   : _fr ? 'Quelque chose a mal tourné. Réessayez!'       : _pt ? 'Algo deu errado. Tente novamente!'           : 'Something went wrong. Try again!';
}
