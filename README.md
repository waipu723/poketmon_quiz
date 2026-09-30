# ⚡ Pokémon Battle Quiz

Flutter로 제작한 **포켓몬 배틀 기술 선택 퀴즈 애플리케이션**입니다.

랜덤으로 선택된 내 포켓몬과 상대 포켓몬을 비교하고,  
주어진 기술 중 가장 효과적인 기술을 선택하는 방식으로 진행됩니다.

단순한 타입 상성뿐 아니라 공격/방어 능력치, STAB, 물리·특수 공격을 함께 계산해
선택한 기술의 효율을 평가합니다.

---

## 🎮 주요 기능

- 랜덤 포켓몬 배틀 생성
- 포켓몬 타입 상성 계산
- 타입 면역 처리
- 이중 타입 상성 계산
- 기술 위력 반영
- 물리 공격 / 특수 공격 구분
- 방어 / 특수방어 능력치 반영
- STAB 보정
- 선택 기술과 최적 기술의 예상 데미지 비교
- 선택 결과에 따른 점수 시스템
- 포켓몬 능력치 및 계산 결과 표시

---

## 🧠 Battle Logic

기술의 예상 데미지는 다음 요소를 기반으로 계산합니다.

```text
Attack Stat / Defense Stat
× Move Power
× STAB
× Type Effectiveness
```

### STAB

사용하는 기술의 타입이 포켓몬의 타입과 같으면:

```text
1.5x
```

의 보정을 적용합니다.

### Type Effectiveness

타입 상성에 따라 다음과 같이 계산합니다.

```text
Super Effective     : 2x
Normal              : 1x
Not Very Effective  : 0.5x
Immune              : 0x
```

이중 타입 포켓몬의 경우 각 타입의 상성을 곱하여 최종 배율을 계산합니다.

예:

```text
2x × 2x = 4x
2x × 0.5x = 1x
0.5x × 0.5x = 0.25x
```

---

## 🏆 Score System

선택한 기술의 예상 데미지를 가장 강한 기술과 비교하여 점수를 부여합니다.

| 선택 효율 | 결과 | 점수 |
|---|---|---:|
| 100% | 🔥 완벽한 선택 | +15 |
| 80% 이상 | 👍 꽤 좋은 선택 | +8 |
| 50% 이상 | 😐 나쁘지 않음 | +2 |
| 50% 미만 | ❌ 비효율적인 선택 | -5 |

같은 문제에서 다른 기술을 눌러 비교할 수 있지만, 점수는 최초 선택에 대해서만 반영됩니다.

---

## 🧩 Pokémon Data

포켓몬 데이터는 JSON 파일에서 불러옵니다.

```text
assets/pokemon_gen1_151.json
```

각 포켓몬은 다음 정보를 가집니다.

```text
Name
Types
Image
HP
Attack
Defense
Special Attack
Special Defense
Speed
Moves
```

현재 프로젝트에서는 **1세대 포켓몬 151종 데이터**를 사용합니다.

---

## 🛠 Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=for-the-badge&logo=json&logoColor=white)

---

## 📁 Project Structure

```text
poketmon_quiz/
├── assets/
│   └── pokemon_gen1_151.json
├── lib/
│   └── main.dart
├── android/
├── ios/
├── macos/
├── web/
├── windows/
├── linux/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Run

Flutter가 설치되어 있어야 합니다.

```bash
flutter pub get
```

실행:

```bash
flutter run
```

연결된 디바이스 확인:

```bash
flutter devices
```

특정 플랫폼에서 실행하려면:

```bash
flutter run -d chrome
```

또는

```bash
flutter run -d macos
```

---

## 💡 Project Goal

포켓몬 타입 상성과 능력치를 단순히 암기하는 것이 아니라,

> **실제 전투 상황에서 어떤 기술이 더 효과적인지 계산하며 학습하는 것**

을 목표로 제작했습니다.

Flutter에서 JSON 데이터를 불러오고,
게임 로직과 UI를 연결하는 과정을 학습하기 위한 프로젝트입니다.

---

## 🔗 Repository

https://github.com/waipu723/poketmon_quiz
