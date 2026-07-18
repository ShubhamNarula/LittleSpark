import 'package:flutter_test/flutter_test.dart';
import '../lib/data/models/letter_model.dart';
import '../lib/data/models/number_model.dart';

void main() {
  test('LetterModel fields test', () {
    const letter = LetterModel(
      letter: 'A',
      word: 'Apple',
      emoji: '🍎',
      funFact: 'Apples come in red, green and yellow colors!',
      colorHex: 0xFFFF6B6B,
    );
    expect(letter.letter, 'A');
    expect(letter.word, 'Apple');
  });

  test('NumberModel fields test', () {
    const number = NumberModel(
      number: 1,
      word: 'One',
      emoji: '🦖',
      funFact: 'You have 1 nose! 👃',
    );
    expect(number.number, 1);
    expect(number.word, 'One');
  });
}
