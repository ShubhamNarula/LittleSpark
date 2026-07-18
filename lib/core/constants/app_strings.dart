class AppStrings {
  static const String appName = 'LittleSpark';
  static const String appTagline = 'Learn. Play. Grow!';
  static const String loadingText = 'Igniting Magic... ✨';
  static const String helloSuperstar = 'Hello, Superstar! 👋';

  // Module Names
  static const String moduleAlphabet = 'A to Z 🔤';
  static const String moduleNumbers = 'Count with Me! 🔢';
  static const String moduleColorsShapes = 'Colors & Shapes 🎨';
  static const String moduleAnimals = 'Animal Kingdom 🐾';
  static const String moduleFruitsVeggies = 'Fruits & Veggies 🍎';
  static const String moduleVoice = 'Say It! 🎤';
  static const String moduleRewards = 'My Rewards 🏅';
  static const String moduleMiniGames = 'Mini Games 🎮'; // Defined but not screens

  // General Buttons/Labels
  static const String hearIt = 'Hear it!';
  static const String gotIt = 'Got it!';
  static const String ok = 'OK';
  static const String back = 'Back';
  static const String keepGoing = 'Keep going!';
  static const String traceItSoon = 'Trace It! Coming Soon ✏️';

  // Dynamic greetings
  static String greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, ready to learn? ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon, let\'s play! 🌤️';
    } else {
      return 'Good Evening, bedtime learning! 🌙';
    }
  }
}
