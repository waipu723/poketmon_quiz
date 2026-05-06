import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BattleQuizPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Pokemon {
  String name;
  List<String> types;
  String img;

  double hp;
  double attack;
  double defense;
  double spAttack;
  double spDefense;
  double speed;
  List<Move> moves;
  Pokemon({
    required this.name,
    required this.types,
    required this.img,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
    required this.moves,
  });
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      types: List<String>.from(json['types']),
      img: json['img'],
      hp: (json['stats']['hp'] as num).toDouble(),
      attack: (json['stats']['attack'] as num).toDouble(),
      defense: (json['stats']['defense'] as num).toDouble(),
      spAttack: (json['stats']['spAttack'] as num).toDouble(),
      spDefense: (json['stats']['spDefense'] as num).toDouble(),
      speed: (json['stats']['speed'] as num).toDouble(),
      moves: (json['moves'] as List)
        .map((m) => Move.fromJson(m))
        .toList(),
    );
  }
}

class Move {
  String name;
  String type;
  int power;
  bool isSpecial;

  Move({
    required this.name,
    required this.type,
    required this.power,
    required this.isSpecial,
  });
  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      name: json['name'],
      type: json['type'],
      power: json['power'],
      isSpecial: json['isSpecial'],
    );
  }
}

class BattleQuizPage extends StatefulWidget {
  const BattleQuizPage({super.key});
  
  @override
  State<BattleQuizPage> createState() => _BattleQuizPageState();
}

class _BattleQuizPageState extends State<BattleQuizPage> {
  Future<void> loadPokemonData() async {
  final String jsonString =
      await rootBundle.loadString('assets/pokemon_gen1_151.json');

  final List data = jsonDecode(jsonString);

  pokemonPool = data.map((e) => Pokemon.fromJson(e)).toList();

  newBattle();

  setState(() {});
}
  Map<String, List<String>> typeWeak = { 
    "fire": ["water", "rock", "ground"], 
    "water": ["electric", "grass"], 
    "electric": ["ground"], 
    "grass": ["fire", "ice", "poison", "flying", "bug"], 
    "ice": ["fire", "fighting", "rock", "steel"], 
    "fighting": ["flying", "psychic", "fairy"], 
    "poison": ["ground", "psychic"], 
    "ground": ["water", "grass", "ice"], 
    "flying": ["electric", "ice", "rock"], 
    "psychic": ["bug", "ghost", "dark"], 
    "bug": ["fire", "flying", "rock"], 
    "rock": ["water", "grass", "fighting", "ground", "steel"], 
    "ghost": ["ghost", "dark"], 
    "dragon": ["ice", "dragon", "fairy"], 
    "dark": ["fighting", "bug", "fairy"], 
    "steel": ["fire", "fighting", "ground"], 
    "fairy": ["poison", "steel"], }; 
    Map<String, List<String>> typeImmune = { 
      "normal": ["ghost"], // 노말 공격 → 고스트 면역 
      "fighting": ["ghost"], // 격투 공격 → 고스트 면역 
      "ghost": ["normal"], // 고스트 공격 → 노말 면역 
      "electric": ["ground"], // 전기 공격 → 땅 면역 
      "psychic": ["dark"], // 에스퍼 공격 → 악 면역 
      "dragon": ["fairy"], // 드래곤 공격 → 페어리 면역 
      "poison": ["steel"], // 독 공격 → 강철 면역 
      }; 
      Map<String, List<String>> typeStrong = { 
        "normal": [], 
        "fire": ["grass", "ice", "bug", "steel"], 
        "water": ["fire", "ground", "rock"], 
        "electric": ["water", "flying"], 
        "grass": ["water", "ground", "rock"], 
        "ice": ["grass", "ground", "flying", "dragon"], 
        "fighting": ["normal", "ice", "rock", "dark", "steel"], 
        "poison": ["grass", "fairy"], 
        "ground": ["fire", "electric", "poison", "rock", "steel"], 
        "flying": ["grass", "fighting", "bug"], 
        "psychic": ["fighting", "poison"], 
        "bug": ["grass", "psychic", "dark"], 
        "rock": ["fire", "ice", "flying", "bug"], 
        "ghost": ["psychic", "ghost"], 
        "dragon": ["dragon"], 
        "dark": ["psychic", "ghost"], 
        "steel": ["ice", "rock", "fairy"], 
        "fairy": ["fighting", "dragon", "dark"], 
      };

  double getEffectiveness(String atk, String def) {
  if (typeImmune[atk]?.contains(def) ?? false) return 0;
  if (typeStrong[atk]?.contains(def) ?? false) return 2;
  if (typeWeak[atk]?.contains(def) ?? false) return 0.5;
  return 1;
}

  double getTotalEffectiveness(String atk, List<String> defs) {
    double result = 1;
    for (var d in defs) {
      result *= getEffectiveness(atk, d);
    }
    return result;
  }

  double calculateDamage(Pokemon atk, Pokemon def, Move move) {
    double atkStat = move.isSpecial ? atk.spAttack : atk.attack;
    double defStat = move.isSpecial ? def.spDefense : def.defense;

    double stab = atk.types.contains(move.type) ? 1.5 : 1;
    double type = getTotalEffectiveness(move.type, def.types);

    return ((atkStat / defStat) * move.power) * stab * type;
  }

  int getBestMoveIndex(Pokemon atk, Pokemon def, List<Move> moves) {
    double best = -1;
    int idx = 0;

    for (int i = 0; i < moves.length; i++) {
      double score = calculateDamage(atk, def, moves[i]);
      if (score > best) {
        best = score;
        idx = i;
      }
    }
    return idx;
  }
  List<Pokemon> pokemonPool = [];

  

  late Pokemon player;
  late Pokemon enemy;
  List<Move> playerMoves = [];

  int score = 0;
  String result = "";

  void newBattle() {
    final rand = Random();

    player = pokemonPool[rand.nextInt(pokemonPool.length)];
    enemy = pokemonPool[rand.nextInt(pokemonPool.length)];

    playerMoves = List.from(player.moves)..shuffle();

    if (playerMoves.length > 4) {
      playerMoves = playerMoves.take(4).toList();
    }
  }

  void next() {
    setState(() {
      newBattle();
      result = "";
    });
  }
  
  void checkMove(int choice) {
  int best = getBestMoveIndex(player, enemy, playerMoves);

  double chosenDamage = calculateDamage(player, enemy, playerMoves[choice]);
  double bestDamage = calculateDamage(player, enemy, playerMoves[best]);

  double ratio = chosenDamage / bestDamage;

  if (ratio == 1) {
    score += 15;
    result = "🔥 완벽한 선택!";
  } else if (ratio >= 0.8) {
    score += 8;
    result = "👍 꽤 좋은 선택!";
  } else if (ratio >= 0.5) {
    score += 2;
    result = "😐 나쁘지 않음";
  } else {
    score -= 5;
    result = "❌ 비효율적인 선택";
  }
  result +=
    "\n\n선택 기술: ${playerMoves[choice].name}"
    "\n내 선택 데미지: ${chosenDamage.toInt()} / 최고 데미지: ${bestDamage.toInt()}"
    "\n타입 상성: ${getTotalEffectiveness(playerMoves[choice].type, enemy.types)}배"
    "\n자속 보정(STAB): ${player.types.contains(playerMoves[choice].type) ? 1.5 : 1.0}배"
    "\n공격 방식: ${playerMoves[choice].isSpecial ? "특수공격" : "물리공격"}"
    "\n\n[내 포켓몬 종족값]"
    "\nHP ${player.hp.toInt()} / Atk ${player.attack.toInt()} / Def ${player.defense.toInt()}"
    "\nSpA ${player.spAttack.toInt()} / SpD ${player.spDefense.toInt()} / Spe ${player.speed.toInt()}"
    "\n\n[상대 포켓몬 종족값]"
    "\nHP ${enemy.hp.toInt()} / Atk ${enemy.attack.toInt()} / Def ${enemy.defense.toInt()}"
    "\nSpA ${enemy.spAttack.toInt()} / SpD ${enemy.spDefense.toInt()} / Spe ${enemy.speed.toInt()}";
  setState(() {});
}

  @override
void initState() {
  super.initState();
  loadPokemonData();
}

  @override
Widget build(BuildContext context) {
  if (pokemonPool.isEmpty) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text("포켓몬 배틀 퀴즈"),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "점수: $score",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pokemonCard("내 포켓몬", player),
              const Text(
                "VS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              _pokemonCard("상대 포켓몬", enemy),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.isEmpty ? "상대에게 가장 효과적인 기술을 선택하세요!" : result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "기술 선택",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: List.generate(playerMoves.length, (i) {
              final move = playerMoves[i];

              return ElevatedButton(
                onPressed: () => checkMove(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      move.name,
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${move.type} / 위력 ${move.power}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: next,
            child: const Text("다음 배틀"),
          ),
        ],
      ),
    ),
  );
}
Widget _pokemonCard(String title, Pokemon p) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Image.network(p.img, height: 90),
          Text(
            p.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            p.types.join(" / "),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
}