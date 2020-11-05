import "package:firebase_admob/firebase_admob.dart";
import "package:flutter/material.dart";
import 'package:gottask/models/pokemon.dart';

enum PlayerState {
  READY,
  PLAY,
  PAUSE,
  END,
}

enum TimerState {
  PLAY,
  PAUSE,
  DONE,
}

enum HandSide {
  Left,
  Right,
}

class TodoColors {
  static const deepPurple = Color(0xFF44427D);
  static const lightOrange = Color(0xFF12947f);
  static const deepYellow = Color(0xFFEEB902);
  static const scaffoldWhite = Color(0xFFF6F5F4);
  static const chocolate = Color(0xFFD2691E);
  static const grassOld = Color(0xFF535F2D);
  static const lightGreen = Color(0xFF8BBC2F);
  static const spiritBlue = Color(0xFF4C6AC4);
  static const blueMoon = Color(0xFF464159);
  static const blueAqua = Color(0xFF0181A0);
  static const spaceGrey = Color(0xFF687C95);
  static const groundPink = Color(0xFFD05D40);
  static const massiveRed = Color(0xFF89202D);
}

List<String> splashScreen = [
  "assets/splash/screen_home.jpg",
  "assets/splash/screen_add_todo.png",
  "assets/splash/screen_task.jpg",
  "assets/splash/screen_task.png",
  "assets/splash/screen_pokemon_all.jpg",
];

String durationFormat(String duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  List<String> elements = duration.split(":");
  List<String> seconds = elements[2].split(".");
  return "${twoDigits(int.parse(elements[0]))}h : ${twoDigits(int.parse(elements[1]))}m : ${twoDigits(int.parse(seconds[0]))}s";
}

String durationFormatByDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  return "${twoDigits(duration.inHours)} : ${twoDigits(duration.inMinutes.remainder(60))} : ${twoDigits(duration.inSeconds.remainder(60))}";
}

int getTaskComplete(List<bool> isDoneAchieve) {
  int res = 0;
  isDoneAchieve.forEach((isDone) {
    if (isDone == true) res++;
  });
  return res;
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>["Gottask", "productive apps", "to-do", "note"],
  childDirected: false,
  testDevices: testDevice != null
      ? <String>[testDevice] // Android emulators are considered test devices
      : null,
);

const double kListViewHeight = 155;

const String testDevice = "Test-id";

const String appId = "ca-app-pub-8520565961626834~6649996964";

const String interstitialId = "ca-app-pub-8520565961626834/1369750120";
// const String interstitialId = "ca-app-pub-3940256099942544/1033173712";

const String bannerId = "ca-app-pub-8520565961626834/2808677078";
// const String bannerId = "ca-app-pub-3940256099942544/6300978111";

const String rewardId = "ca-app-pub-8520565961626834/9794007386";
// const String rewardId = "ca-app-pub-3940256099942544/5224354917";

// List<String> icons = [
//   "Icons.star_border",
//   "Icons.airline_seat_individual_suite",
//   "Icons.library_books",
//   "Icons.library_music",
//   "Icons.wallpaper",
//   "Icons.warning",
//   "Icons.wifi",
//   "Icons.work",
//   "Icons.wb_incandescent",
//   "Icons.hot_tub",
//   "Icons.import_contacts",
//   "Icons.important_devices",
//   "Icons.screen_lock_portrait",
//   "Icons.rowing",
//   "Icons.description",
//   "Icons.directions_bike",
//   "Icons.email",
//   "Icons.fastfood",
//   "fa.heart",
//   "fa.heartbeat",
//   "fa.dog",
// ];

List<String> colors = [
  TodoColors.blueMoon.toString().substring(6, 16),
  TodoColors.deepPurple.toString().substring(6, 16),
  TodoColors.massiveRed.toString().substring(6, 16),
  TodoColors.grassOld.toString().substring(6, 16),
  TodoColors.blueAqua.toString().substring(6, 16),
  TodoColors.chocolate.toString().substring(6, 16),
  TodoColors.spaceGrey.toString().substring(6, 16),
  TodoColors.spiritBlue.toString().substring(6, 16),
  TodoColors.groundPink.toString().substring(6, 16),
  TodoColors.lightGreen.toString().substring(6, 16),
  TodoColors.lightOrange.toString().substring(6, 16),
  TodoColors.deepYellow.toString().substring(6, 16),
];

extension ParseColor on List<String> {
  Color parseColor(int indexColor) => Color(int.parse(colors[indexColor]));
}

List<Map<String, dynamic>> catagories = [
  {
    "name": "Grocery",
    "iconData": Icons.shopping_basket,
  },
  {
    "name": "Work",
    "iconData": Icons.work,
  },
  {
    "name": "Study",
    "iconData": Icons.library_books,
  },
  {
    "name": "Hobby",
    "iconData": Icons.weekend,
  },
  {
    "name": "Event",
    "iconData": Icons.event,
  },
  {
    "name": "Party",
    "iconData": Icons.local_play,
  },
  {
    "name": "Relax",
    "iconData": Icons.hot_tub,
  },
  {
    "name": "Reminder",
    "iconData": Icons.edit,
  },
  {
    "name": "Planning",
    "iconData": Icons.calendar_today,
  },
];

Map<String, String> audioFile = {
  "Caught_Pokemon": "musics/caught_pokemon.mp3",
  "Level_Up": "musics/level_up.mp3",
};

List<String> pokeballImages = [
  "assets/png/038.png",
  "assets/png/017.png",
  "assets/png/019.png",
  "assets/png/024.png",
  "assets/png/028.png",
  "assets/png/030.png",
  "assets/png/035.png",
  "assets/png/040.png",
  "assets/png/048.png",
  "assets/png/055.png",
];

Map<String, Color> tagColor = {
  "Bug": Color(0xFF729F3F),
  "Dragon": Color(0xFFF16E57),
  "Fairy": Color(0xFFFDB9E9),
  "Ghost": Color(0xFF7B62A3),
  "Ground": Color(0xFFF7DE3F),
  "Normal": Color(0xFFA4ACAF),
  "Steel": Color(0xFF9EB7B8),
  "Dark": Color(0xFF707070),
  "Electric": Color(0xFFEED535),
  "Fighting": Color(0xFFD56723),
  "Grass": Color(0xFF9BCC50),
  "Poison": Color(0xFFB97FC9),
  "Water": Color(0xFF4592C4),
  "Rock": Color(0xFFA38C21),
  "Fire": Color(0xFFFD7D24),
  "Flying": Color(0xFF3DC7EF),
  "Ice": Color(0xFF51C4E7),
  "Psychic": Color(0xFFF366B9),
};

// List<Map<String, dynamic>> disaster = [
//   {
//     "name": "Nước biển dâng",
//     "description":
//         "Mực nước biển dâng do khí hậu trái đất nóng lên cộng với hiện tượng băng tan ở hai cực.",
//     "imageURL": [
//       "https://images.pexels.com/photos/753619/pexels-photo-753619.jpeg"
//     ],
//     "damage": {
//       "affected_people": "480 triệu người",
//       "dangerous_level": 4.5,
//       "affect": ["Nông nghiệp", "Đất đai"]
//     },
//     "icon": "sea_rises.png"
//   },
//   {
//     "name": "Cháy rừng",
//     "description":
//         "Cháy rừng diễn ra do thời tiết nắng nóng, gây hậu quả to lớn về cả về con người và vật chất.",
//     "imageURL": [
//       "https://images.pexels.com/photos/266487/pexels-photo-266487.jpeg"
//     ],
//     "damage": {
//       "affected_people": "10 triệu người/năm",
//       "dangerous_level": 2,
//       "affect": [
//         "Nông nghiệp",
//         "Hệ sinh thái",
//         "Cơ sở vật chất",
//         "Đất lâm nghiệp"
//       ]
//     },
//     "icon": "forest_fire.png"
//   },
//   {
//     "name": "Hạn hán",
//     "description":
//         "Nắng nóng kéo dài và liên tục phá vỡ các kỉ lục đã gây ra hạn hán tại nhiều vùng miền.",
//     "imageURL": [
//       "https://images.pexels.com/photos/2496572/pexels-photo-2496572.jpeg"
//     ],
//     "damage": {
//       "affected_people": "55 triệu người/năm",
//       "dangerous_level": 4,
//       "affect": ["Nông nghiệp"]
//     },
//     "icon": "drought.png"
//   },
//   {
//     "name": "Bão nhiệt đới",
//     "description": "Các cơn bão nhiệt đới diễn ra ở khắp nơi trên thế giới.",
//     "imageURL": [
//       "https://images.pexels.com/photos/71116/hurricane-earth-satellite-tracking-71116.jpeg"
//     ],
//     "damage": {
//       "affected_people": "500 triệu người/năm",
//       "dangerous_level": 5,
//       "affect": ["Kinh tế", "Công nghiệp", "Cơ sở vật chất", "Nông nghiệp"]
//     },
//     "icon": "hurricane.png"
//   },
//   {
//     "name": "Ô nhiễm không khí",
//     "description": "Chất lượng không khí ở mức độc hại cho con người",
//     "imageURL": [
//       "https://images.pexels.com/photos/1697357/pexels-photo-1697357.jpeg"
//     ],
//     "damage": {
//       "affected_people": "4 tỉ người",
//       "dangerous_level": 5,
//       "affect": ["Sức khỏe", "Giao thông"]
//     },
//     "icon": "air_pollution.png"
//   },
//   {
//     "name": "Lốc xoáy",
//     "description": "Thường hay xuất hiện ở vùng nhiệt đới trong các cơn dông.",
//     "imageURL": [
//       "https://images.pexels.com/photos/1446076/pexels-photo-1446076.jpeg"
//     ],
//     "damage": {
//       "affected_people": "1 triệu người/năm",
//       "dangerous_level": 2,
//       "affect": ["Nông nghiệp", "Cơ sở vật chất"]
//     },
//     "icon": "tornado.png"
//   },
//   {
//     "name": "Núi lửa",
//     "description":
//         "Các hoạt động địa chất dưới lòng đất dẫn tới những vụ phun trào núi lửa.",
//     "imageURL": [
//       "https://images.pexels.com/photos/4220967/pexels-photo-4220967.jpeg"
//     ],
//     "damage": {
//       "affected_people": "500 000 người/năm",
//       "dangerous_level": 1.5,
//       "affect": ["Bầu khí quyển", "Đất đai"]
//     },
//     "icon": "volcano.png"
//   },
//   {
//     "name": "Các cơn dông",
//     "description": "Xảy ra vào mùa hè do sự chênh lệch nhiệt độ đột ngột",
//     "imageURL": [
//       "https://images.pexels.com/photos/158163/clouds-cloudporn-weather-lookup-158163.jpeg"
//     ],
//     "damage": {
//       "affected_people": "5 triệu người/năm",
//       "dangerous_level": 2,
//       "affect": ["Nông nghiệp"]
//     },
//     "icon": "storm.png"
//   },
//   {
//     "name": "Lũ lụt",
//     "description": "Lũ lụt gây ra bởi mưa sau các cơn bão.",
//     "imageURL": [
//       "https://images.unsplash.com/photo-1580993777851-40514758f716"
//     ],
//     "damage": {
//       "affected_people": "10 triệu người/năm",
//       "dangerous_level": 3,
//       "affect": ["Nông nghiệp", "Cơ sở vật chất"]
//     },
//     "icon": "flood.png"
//   },
//   {
//     "name": "Mưa Axit",
//     "description":
//         "Khí thải công nghiệp tích tụ trong bầu khí quyển lâu ngày sẽ gây ra hiện tượng mưa Axit",
//     "imageURL": [
//       "https://images.unsplash.com/photo-1428592953211-077101b2021b"
//     ],
//     "damage": {
//       "affected_people": "5 triệu người/năm",
//       "dangerous_level": 3,
//       "affect": ["Nông nghiệp", "Hệ sinh thái", "Sức khỏe"]
//     },
//     "icon": "axit_rain.png"
//   }
// ];

List<Pokemon> pokedex = [
  Pokemon.fromJson(
    {
      "name": "Aron",
      "imageURL": "assets/png/001.png",
      "HP": "50",
      "Attack": "70",
      "Defense": "100",
      "speed": "30",
      "spAtk": "40",
      "spDef": "40",
      "height": "1' 04",
      "weight": "132.3 lbs",
      "category": "Iron Armor",
      "type": {
        "en": ["Steel", "Rock"],
        "vi": ["Thép", "Đá"],
      },
      "weaknesses": {
        "en": ["Fighting", "Ground", "Water"],
        "vi": ["Chiến đấu", "Đất", "Nước"],
      },
      "introduction": {
        "en":
            "This Pokémon has a body of steel. To make its body, Aron feeds on iron ore that it digs from mountains. Occasionally, it causes major trouble by eating bridges and rails.",
        "vi":
            "Pokémon này có cơ thể bằng thép. Để tạo ra cơ thể của nó, Aron ăn quặng sắt mà nó đào được từ núi. Đôi khi, nó gây ra rắc rối lớn bằng cách ăn cầu và đường ray."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Bellsprout",
      "imageURL": "assets/png/002.png",
      "HP": "50",
      "Attack": "75",
      "Defense": "35",
      "speed": "40",
      "spAtk": "70",
      "spDef": "30",
      "height": "2' 04",
      "weight": "8.8 lbs",
      "category": "Flower",
      "type": {
        "en": ["Grass", "Poison"],
        "vi": ["Cỏ", "Độc"],
      },
      "weaknesses": {
        "en": ["Fire", "Flying", "Ice", "Psychic"],
        "vi": ["Lửa", "Bay", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Bellsprout's thin and flexible body lets it bend and sway to avoid any attack, however strong it may be. From its mouth, this Pokémon spits a corrosive fluid that melts even iron.",
        "vi":
            "Cơ thể mỏng và linh hoạt của Bellsprout cho phép nó uốn cong và lắc lư để tránh bất kỳ đòn tấn công nào, dù nó có mạnh đến đâu. Từ miệng, Pokémon này phun ra một chất lỏng ăn mòn làm tan chảy cả sắt."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Breloom",
      "imageURL": "assets/png/003.png",
      "HP": "60",
      "Attack": "130",
      "Defense": "80",
      "speed": "70",
      "spAtk": "60",
      "spDef": "60",
      "height": "3' 11",
      "weight": "86.4 lbs",
      "category": "Mushroom",
      "type": {
        "en": ["Grass", "Fighting"],
        "vi": ["Cỏ", "Chiến đấu"],
      },
      "weaknesses": {
        "en": ["Flying", "Fire", "Ice", "Poison", "Psychic", "Fairy"],
        "vi": ["Bay", "Lửa", "Băng", "Độc", "Ngoại cảm", "Tiên"],
      },
      "introduction": {
        "en":
            "Breloom closes in on its foe with light and sprightly footwork, then throws punches with its stretchy arms. This Pokémon's fighting technique puts boxers to shame.",
        "vi":
            "Breloom áp sát kẻ thù bằng động tác chân nhẹ nhàng và nhanh nhẹn, sau đó tung ra những cú đấm bằng cánh tay co giãn của nó. Kỹ thuật chiến đấu của Pokémon này khiến các võ sĩ phải xấu hổ."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Bulbasaur",
      "imageURL": "assets/png/004.png",
      "HP": "45",
      "Attack": "49",
      "Defense": "49",
      "speed": "45",
      "spAtk": "65",
      "spDef": "65",
      "height": "2' 04",
      "weight": "15.2 lbs",
      "category": "Seed",
      "type": {
        "en": ["Grass", "Poison"],
        "vi": ["Cỏ", "Độc"],
      },
      "weaknesses": {
        "en": ["Fire", "Flying", "Ice", "Psychic"],
        "vi": ["Lửa", "Bay", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Bulbasaur can be seen napping in bright sunlight. There is a seed on its back. By soaking up the sun's rays, the seed grows progressively larger.",
        "vi":
            "Bulbasaur có thể được nhìn thấy đang chợp mắt trong ánh nắng chói chang. Trên lưng nó có một hạt giống. Bằng cách hấp thụ các tia nắng mặt trời, hạt giống sẽ lớn dần lên."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Cacnea",
      "imageURL": "assets/png/005.png",
      "HP": "50",
      "Attack": "85",
      "Defense": "40",
      "speed": "35",
      "spAtk": "85",
      "spDef": "40",
      "height": "1' 04",
      "weight": "113.1 lbs",
      "category": "Cactus",
      "type": {
        "en": ["Grass"],
        "vi": ["Cỏ"],
      },
      "weaknesses": {
        "en": ["Bug", "Fire", "Flying", "Ice", "Poison"],
        "vi": ["Bọ", "Lửa", "Bay", "Băng", "Độc"],
      },
      "introduction": {
        "en":
            "Cacnea lives in arid locations such as deserts. It releases a strong aroma from its flower to attract prey. When prey comes near, this Pokémon shoots sharp thorns from its body to bring the victim down.",
        "vi":
            "Cacnea sống ở những nơi khô cằn như sa mạc. Nó tỏa ra mùi thơm nồng từ hoa để thu hút con mồi. Khi con mồi đến gần, loài Pokémon này bắn ra những chiếc gai sắc nhọn từ cơ thể để hạ gục nạn nhân",
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Charmander",
      "imageURL": "assets/png/007.png",
      "HP": "39",
      "Attack": "52",
      "Defense": "43",
      "speed": "65",
      "spAtk": "60",
      "spDef": "50",
      "height": "2' 00",
      "weight": "18.7 lbs",
      "category": "Lizard",
      "type": {
        "en": ["Fire"],
        "vi": ["Lửa"],
      },
      "weaknesses": {
        "en": ["Ground", "Rock", "Water"],
        "vi": ["Đất", "Đá", "Nước"],
      },
      "introduction": {
        "en":
            "The flame that burns at the tip of its tail is an indication of its emotions. The flame wavers when Charmander is enjoying itself. If the Pokémon becomes enraged, the flame burns fiercely.",
        "vi":
            "Ngọn lửa bùng cháy ở đầu đuôi là biểu hiện cho cảm xúc của nó. Ngọn lửa dao động khi Charmander đang tận hưởng. Nếu Pokémon trở nên tức giận, ngọn lửa sẽ bùng cháy dữ dội."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Chikorita",
      "imageURL": "assets/png/008.png",
      "HP": "45",
      "Attack": "49",
      "Defense": "65",
      "speed": "45",
      "spAtk": "49",
      "spDef": "65",
      "height": "2' 11",
      "weight": "14.1 lbs",
      "category": "Leaf",
      "type": {
        "en": ["Grass"],
        "vi": ["Cỏ"],
      },
      "weaknesses": {
        "en": ["Bug", "Fire", "Flying", "Ice", "Poison"],
        "vi": ["Bọ", "Lửa", "Bay", "Băng", "Độc"],
      },
      "introduction": {
        "en":
            "In battle, Chikorita waves its leaf around to keep the foe at bay. However, a sweet fragrance also wafts from the leaf, becalming the battling Pokémon and creating a cozy, friendly atmosphere all around.",
        "vi":
            "Trong trận chiến, Chikorita vẫy lá xung quanh để ngăn chặn kẻ thù. Tuy nhiên, một hương thơm ngọt ngào cũng thoang thoảng từ chiếc lá, đánh gục các Pokémon đang chiến đấu và tạo ra một bầu không khí thân thiện, ấm cúng xung quanh."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Chinchou",
      "imageURL": "assets/png/009.png",
      "HP": "75",
      "Attack": "38",
      "Defense": "38",
      "speed": "67",
      "spAtk": "56",
      "spDef": "56",
      "height": "1' 08",
      "weight": "26.5 lbs",
      "category": "Angler",
      "type": {
        "en": ["Water", "Electric"],
        "vi": ["Nước", "Điện"],
      },
      "weaknesses": {
        "en": ["Grass", "Ground"],
        "vi": ["Cỏ", "Đất"],
      },
      "introduction": {
        "en":
            "Chinchou lets loose positive and negative electrical charges from its two antennas to make its prey faint. This Pokémon flashes its electric lights to exchange signals with others.",
        "vi":
            "Chinchou thả lỏng điện tích âm và dương từ hai ăng-ten của nó để làm cho con mồi của nó ngất đi. Pokémon này nhấp nháy đèn điện để trao đổi tín hiệu với những con khác."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Diglett",
      "imageURL": "assets/png/010.png",
      "HP": "10",
      "Attack": "55",
      "Defense": "25",
      "speed": "95",
      "spAtk": "35",
      "spDef": "45",
      "height": "0' 08",
      "weight": "1.8 lbs",
      "category": "Mole",
      "type": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "weaknesses": {
        "en": ["Grass", "Ice", "Water"],
        "vi": ["Cỏ", "Băng", "Nước"],
      },
      "introduction": {
        "en":
            "Diglett are raised in most farms. The reason is simple— wherever this Pokémon burrows, the soil is left perfectly tilled for planting crops. This soil is made ideal for growing delicious vegetables.",
        "vi":
            "Diglett được nuôi ở hầu hết các trang trại. Lý do rất đơn giản - bất cứ nơi nào Pokémon này đào hang, đất vẫn được xới tơi để trồng cây. Loại đất này được làm lý tưởng để trồng các loại rau ngon."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Ditto",
      "imageURL": "assets/png/011.png",
      "HP": "48",
      "Attack": "48",
      "Defense": "48",
      "speed": "48",
      "spAtk": "48",
      "spDef": "48",
      "height": "1' 00",
      "weight": "8.8 lbs",
      "category": "Transform",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "Ditto rearranges its cell structure to transform itself into other shapes. However, if it tries to transform itself into something by relying on its memory, this Pokémon manages to get details wrong.",
        "vi":
            "Ditto sắp xếp lại cấu trúc tế bào của nó để tự biến đổi thành các hình dạng khác. Tuy nhiên, nếu nó cố gắng biến mình thành thứ gì đó bằng cách dựa vào trí nhớ của mình, Pokémon này sẽ hiểu sai chi tiết."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Duskull",
      "imageURL": "assets/png/012.png",
      "HP": "20",
      "Attack": "40",
      "Defense": "90",
      "speed": "25",
      "spAtk": "30",
      "spDef": "90",
      "height": "2' 07",
      "weight": "33.1 lbs",
      "category": "Requiem",
      "type": {
        "en": ["Ghost"],
        "vi": ["Bóng ma"],
      },
      "weaknesses": {
        "en": ["Dark", "Ghost"],
        "vi": ["Bóng tối", "Bóng ma"],
      },
      "introduction": {
        "en":
            "Duskull can pass through any wall no matter how thick it may be. Once this Pokémon chooses a target, it will doggedly pursue the intended victim until the break of dawn.",
        "vi":
            "Duskull có thể xuyên qua bất kỳ bức tường nào dù nó có dày đến đâu. Một khi Pokémon này chọn mục tiêu, nó sẽ kiên quyết theo đuổi nạn nhân đã định cho đến khi bình minh ló dạng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Exeggutor",
      "imageURL": "assets/png/014.png",
      "HP": "95",
      "Attack": "95",
      "Defense": "85",
      "speed": "55",
      "spAtk": "125",
      "spDef": "75",
      "height": "6' 07",
      "weight": "264.6 lbs",
      "category": "Coconut",
      "type": {
        "en": ["Grass", "Psychic"],
        "vi": ["Cỏ", "Psychic"],
      },
      "weaknesses": {
        "en": ["Bug", "Dark", "Fire", "Flying", "Ghost", "Ice", "Poison"],
        "vi": ["Bọ", "Bóng tối", "Lửa", "Bay", "Bóng ma", "Băng", "Độc"],
      },
      "introduction": {
        "en":
            "Exeggutor originally came from the tropics. Its heads steadily grow larger from exposure to strong sunlight. It is said that when the heads fall off, they group together to form Exeggcute.",
        "vi":
            "Exeggutor ban đầu đến từ vùng nhiệt đới. Đầu của nó lớn dần lên khi tiếp xúc với ánh sáng mặt trời mạnh. Người ta nói rằng khi những chiếc đầu rơi ra, chúng sẽ nhóm lại với nhau để tạo thành Exeggcute."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Gastly",
      "imageURL": "assets/png/015.png",
      "HP": "30",
      "Attack": "35",
      "Defense": "30",
      "speed": "80",
      "spAtk": "100",
      "spDef": "35",
      "height": "4' 03",
      "weight": "0.2 lbs",
      "category": "Gas",
      "type": {
        "en": ["Ghost", "Poison"],
        "vi": ["Bóng ma", "Độc"],
      },
      "weaknesses": {
        "en": ["Dark", "Ghost", "Psychic"],
        "vi": ["Dark", "Bóng ma", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Gastly is largely composed of gaseous matter. When exposed to a strong wind, the gaseous body quickly dwindles away. Groups of this Pokémon cluster under the eaves of houses to escape the ravages of wind.",
        "vi":
            "Gastly chủ yếu được cấu tạo từ thể khí. Khi gặp gió mạnh, thể khí sẽ nhanh chóng biến mất. Các nhóm Pokémon này tụ tập dưới mái hiên của những ngôi nhà để thoát khỏi sự tàn phá của gió."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Gloom",
      "imageURL": "assets/png/016.png",
      "HP": "60",
      "Attack": "65",
      "Defense": "70",
      "speed": "40",
      "spAtk": "85",
      "spDef": "75",
      "height": "2' 07",
      "weight": "19.0 lbs",
      "category": "Weed",
      "type": {
        "en": ["Poison", "Grass"],
        "vi": ["Độc", "Cỏ"],
      },
      "weaknesses": {
        "en": ["Fire", "Flying", "Ice", "Psychic"],
        "vi": ["Lửa", "Bay", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Gloom releases a foul fragrance from the pistil of its flower. When faced with danger, the stench worsens. If this Pokémon is feeling calm and secure, it does not release its usual stinky aroma.",
        "vi":
            "Gloom tiết ra một mùi thơm từ nhụy hoa của nó. Khi đối mặt với nguy hiểm, mùi hôi thối càng nặng thêm. Nếu Pokémon này cảm thấy bình tĩnh và an toàn, nó sẽ không tỏa ra mùi hôi thối thường thấy."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Gulpin",
      "imageURL": "assets/png/018.png",
      "HP": "70",
      "Attack": "43",
      "Defense": "53",
      "speed": "40",
      "spAtk": "43",
      "spDef": "53",
      "height": "1' 04",
      "weight": "22.7 lbs",
      "category": "Stomach",
      "type": {
        "en": ["Poison"],
        "vi": ["Độc"],
      },
      "weaknesses": {
        "en": ["Ground", "Psychic"],
        "vi": ["Đất", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Virtually all of Gulpin's body is its stomach. As a result, it can swallow something its own size. This Pokémon's stomach contains a special fluid that digests anything.",
        "vi":
            "Hầu như toàn bộ cơ thể của Gulpin là dạ dày của nó. Kết quả là nó có thể nuốt một thứ gì đó có kích thước bằng chính nó. Dạ dày của Pokémon này chứa một chất lỏng đặc biệt có thể tiêu hóa bất cứ thứ gì."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Hoothoot",
      "imageURL": "assets/png/020.png",
      "HP": "60",
      "Attack": "30",
      "Defense": "30",
      "speed": "50",
      "spAtk": "36",
      "spDef": "56",
      "height": "2' 04",
      "weight": "46.7 lbs",
      "category": "Owl",
      "type": {
        "en": ["Flying", "Normal"],
        "vi": ["Bay", "Bình thường"],
      },
      "weaknesses": {
        "en": ["Electric", "Ice", "Rock"],
        "vi": ["Điện", "Đá", "Băng"],
      },
      "introduction": {
        "en":
            "Hoothoot has an internal organ that senses and tracks the earth's rotation. Using this special organ, this Pokémon begins hooting at precisely the same time every day.",
        "vi":
            "Hoothoot có một cơ quan nội tạng cảm nhận và theo dõi chuyển động quay của trái đất. Sử dụng cơ quan đặc biệt này, Pokémon này bắt đầu cất cánh chính xác vào cùng một thời điểm mỗi ngày."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Hoppip",
      "imageURL": "assets/png/021.png",
      "HP": "35",
      "Attack": "35",
      "Defense": "40",
      "speed": "50",
      "spAtk": "35",
      "spDef": "55",
      "height": "1' 04",
      "weight": "1.1 lbs",
      "category": "Cottonweed",
      "type": {
        "en": ["Grass", "Flying"],
        "vi": ["Cỏ", "Bay"],
      },
      "weaknesses": {
        "en": ["Ice", "Fire", "Flying", "Poison", "Rock"],
        "vi": ["Băng", "Lửa", "Bay", "Chất độc", "Đá"],
      },
      "introduction": {
        "en":
            "This Pokémon drifts and floats with the wind. If it senses the approach of strong winds, Hoppip links its leaves with other Hoppip to prepare against being blown away.",
        "vi":
            "Pokémon này trôi và lơ lửng theo gió. Nếu nó cảm nhận được sự tiếp cận của gió mạnh, Hoppip sẽ liên kết các lá của nó với các Hoppip khác để chuẩn bị chống lại việc bị thổi bay."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Jigglypuff",
      "imageURL": "assets/png/022.png",
      "HP": "115",
      "Attack": "45",
      "Defense": "20",
      "speed": "20",
      "spAtk": "45",
      "spDef": "25",
      "height": "1' 08",
      "weight": "12.1 lbs",
      "category": "Balloon",
      "type": {
        "en": ["Fairy", "Normal"],
        "vi": ["Tiên", "Bình thường"],
      },
      "weaknesses": {
        "en": ["Steel", "Poison"],
        "vi": ["Thép", "Độc"],
      },
      "introduction": {
        "en":
            "Jigglypuff's vocal cords can freely adjust the wavelength of its voice. This Pokémon uses this ability to sing at precisely the right wavelength to make its foes most drowsy.",
        "vi":
            "Dây thanh quản của Jigglypuff có thể tự do điều chỉnh bước sóng giọng nói của nó. Pokémon này sử dụng khả năng này để hát ở chính xác bước sóng phù hợp để khiến kẻ thù buồn ngủ nhất."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Jolteon",
      "imageURL": "assets/png/013.png",
      "HP": "65",
      "Attack": "65",
      "Defense": "60",
      "speed": "130",
      "spAtk": "110",
      "spDef": "95",
      "height": "2' 07",
      "weight": "54.0 lbs",
      "category": "Lightning",
      "type": {
        "en": ["Electric"],
        "vi": ["Điện"],
      },
      "weaknesses": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "introduction": {
        "en":
            "Jolteon's cells generate a low level of electricity. This power is amplified by the static electricity of its fur, enabling the Pokémon to drop thunderbolts. The bristling fur is made of electrically charged needles.",
        "vi":
            "Tế bào của Jolteon tạo ra một mức điện thấp. Sức mạnh này được khuếch đại bởi tĩnh điện của bộ lông của nó, giúp Pokémon có thể thả ra các tia sét. Bộ lông tua tủa được làm bằng kim nhiễm điện."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Ledyba",
      "imageURL": "assets/png/023.png",
      "HP": "40",
      "Attack": "20",
      "Defense": "30",
      "speed": "55",
      "spAtk": "40",
      "spDef": "80",
      "height": "3' 03",
      "weight": "23.8 lbs",
      "category": "Five Star",
      "type": {
        "en": ["Bug", "Flying"],
        "vi": ["Bọ", "Bay"],
      },
      "weaknesses": {
        "en": ["Rock", "Electric", "Fire", "Flying", "Ice"],
        "vi": ["Đá", "Đá", "Lửa", "Bay", "Băng"],
      },
      "introduction": {
        "en":
            "Ledyba secretes an aromatic fluid from where its legs join its body. This fluid is used for communicating with others. This Pokémon conveys its feelings to others by altering the fluid's scent.",
        "vi":
            "Ledyba tiết ra một chất lỏng thơm từ nơi chân của nó kết hợp với cơ thể của nó. Chất lỏng này được sử dụng để giao tiếp với người khác. Pokémon này truyền cảm xúc của mình cho người khác bằng cách thay đổi mùi của chất lỏng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Magnemite",
      "imageURL": "assets/png/025.png",
      "HP": "25",
      "Attack": "35",
      "Defense": "70",
      "speed": "45",
      "spAtk": "95",
      "spDef": "55",
      "height": "1' 00",
      "weight": "13.2 lbs",
      "category": "Magnet",
      "type": {
        "en": ["Electric", "Steel"],
        "vi": ["Điện", "Thép"],
      },
      "weaknesses": {
        "en": ["Ground", "Fire", "Fighting"],
        "vi": ["Đất", "Lửa", "Chiến đấu"],
      },
      "introduction": {
        "en":
            "Magnemite attaches itself to power lines to feed on electricity. If your house has a power outage, check your circuit breakers. You may find a large number of this Pokémon clinging to the breaker box.",
        "vi":
            "Magnemite tự bám vào đường dây điện để nuôi điện. Nếu nhà bạn bị mất điện, hãy kiểm tra cầu dao. Bạn có thể tìm thấy một số lượng lớn Pokémon này bám vào hộp cầu dao."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Marill",
      "imageURL": "assets/png/026.png",
      "HP": "70",
      "Attack": "20",
      "Defense": "50",
      "speed": "40",
      "spAtk": "20",
      "spDef": "50",
      "height": "1' 04",
      "weight": "18.7 lbs",
      "category": "Aqua Mouse",
      "type": {
        "en": ["Water", "Fairy"],
        "vi": ["Nước", "Tiên"],
      },
      "weaknesses": {
        "en": ["Electric", "Grass", "Poison"],
        "vi": ["Điện", "Cỏ", "Độc"],
      },
      "introduction": {
        "en":
            "Marill's oil-filled tail acts much like a life preserver. If you see just its tail bobbing on the water's surface, it's a sure indication that this Pokémon is diving beneath the water to feed on aquatic plants.",
        "vi":
            "Chiếc đuôi chứa đầy dầu của Marill hoạt động giống như một vật bảo tồn sự sống. Nếu bạn chỉ thấy đuôi của nó nhấp nhô trên mặt nước, đó là dấu hiệu chắc chắn rằng Pokémon này đang lặn dưới mặt nước để ăn thực vật thủy sinh."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Masquerain",
      "imageURL": "assets/png/027.png",
      "HP": "70",
      "Attack": "60",
      "Defense": "62",
      "speed": "80",
      "spAtk": "100",
      "spDef": "82",
      "height": "2' 07",
      "weight": "7.9 lbs",
      "category": "Eyeball",
      "type": {
        "en": ["Bug", "Flying"],
        "vi": ["Bọ", "Bay"],
      },
      "weaknesses": {
        "en": ["Rock", "Electric", "Fire", "Flying", "Ice"],
        "vi": ["Đá", "Điện", "Lửa", "Bay", "Băng"],
      },
      "introduction": {
        "en":
            "Masquerain intimidates enemies with the eyelike patterns on its antennas. This Pokémon flaps its four wings to freely fly in any direction—even sideways and backwards—as if it were a helicopter.",
        "vi":
            "Masquerain đe dọa kẻ thù bằng những họa tiết giống như thật trên ăng-ten của nó. Pokémon này vỗ bốn cánh để tự do bay theo bất kỳ hướng nào — kể cả sang ngang và ngược lại — như thể nó là một chiếc trực thăng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Meowth",
      "imageURL": "assets/png/029.png",
      "HP": "40",
      "Attack": "45",
      "Defense": "35",
      "speed": "90",
      "spAtk": "40",
      "spDef": "40",
      "height": "1' 04",
      "weight": "9.3 lbs",
      "category": "Scratch Cat",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "Meowth withdraws its sharp claws into its paws to slinkily sneak about without making any incriminating footsteps. For some reason, this Pokémon loves shiny coins that glitter with light.",
        "vi":
            "Meowth rút móng vuốt sắc nhọn của nó vào bàn chân để lén lút lẻn vào mà không gây ra bất kỳ bước chân buộc tội nào. Vì lý do nào đó, Pokémon này rất thích những đồng xu sáng bóng lấp lánh ánh sáng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Numel",
      "imageURL": "assets/png/032.png",
      "HP": "60",
      "Attack": "60",
      "Defense": "40",
      "speed": "35",
      "spAtk": "65",
      "spDef": "45",
      "height": "2' 04",
      "weight": "52.9 lbs",
      "category": "Numb",
      "type": {
        "en": ["Fire", "Ground"],
        "vi": ["Lửa", "Đất"],
      },
      "weaknesses": {
        "en": ["Water", "Ground"],
        "vi": ["Nước", "Đất"],
      },
      "introduction": {
        "en":
            "Numel is extremely dull witted—it doesn't notice being hit. However, it can't stand hunger for even a second. This Pokémon's body is a seething cauldron of boiling magma.",
        "vi":
            "Numel cực kỳ lém lỉnh - nó không nhận thấy bị trúng đạn. Tuy nhiên, nó không thể chịu được cơn đói dù chỉ một giây. Cơ thể Pokémon này là một vạc magma sôi sục."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Oddish",
      "imageURL": "assets/png/033.png",
      "HP": "45",
      "Attack": "50",
      "Defense": "55",
      "speed": "30",
      "spAtk": "75",
      "spDef": "65",
      "height": "1' 08",
      "weight": "11.9 lbs",
      "category": "Weed",
      "type": {
        "en": ["Poison", "Grass"],
        "vi": ["Độc", "Cỏ"],
      },
      "weaknesses": {
        "en": ["Fire", "Flying", "Ice", "Psychic"],
        "vi": ["Lửa", "Bay", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "During the daytime, Oddish buries itself in soil to absorb nutrients from the ground using its entire body. The more fertile the soil, the glossier its leaves become.",
        "vi":
            "Vào ban ngày, Oddish vùi mình trong đất để hấp thụ chất dinh dưỡng từ mặt đất bằng cách sử dụng toàn bộ cơ thể của mình. Đất càng màu mỡ, lá của nó càng bóng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Omanyte",
      "imageURL": "assets/png/034.png",
      "HP": "35",
      "Attack": "40",
      "Defense": "100",
      "speed": "35",
      "spAtk": "90",
      "spDef": "55",
      "height": "1' 04",
      "weight": "16.5 lbs",
      "category": "spiral",
      "type": {
        "en": ["Rock", "Water"],
        "vi": ["Đá", "Nước"],
      },
      "weaknesses": {
        "en": ["Grass", "Electric", "Fighting", "Ground"],
        "vi": ["Cỏ", "Điện", "Chiến đấu", "Đất"],
      },
      "introduction": {
        "en":
            "Omanyte is one of the ancient and long-since-extinct Pokémon that have been regenerated from fossils by people. If attacked by an enemy, it withdraws itself inside its hard shell.",
        "vi":
            "Omanyte là một trong những Pokémon cổ đại và đã tuyệt chủng từ lâu, được con người tái sinh từ hóa thạch. Nếu bị kẻ thù tấn công, nó sẽ tự rút lui bên trong lớp vỏ cứng của mình."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Onix",
      "imageURL": "assets/png/006.png",
      "HP": "35",
      "Attack": "45",
      "Defense": "160",
      "speed": "70",
      "spAtk": "30",
      "spDef": "45",
      "height": "28' 10",
      "weight": "463.0 lbs",
      "category": "Rock Snake",
      "type": {
        "en": ["Rock", "Ground"],
        "vi": ["Đá", "Đất"],
      },
      "weaknesses": {
        "en": ["Grass", "Water", "Fighting", "Ground", "Ice", "Psychic"],
        "vi": ["Cỏ", "Nước", "Chiến đấu", "Đất", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Onix has a magnet in its brain. It acts as a compass so that this Pokémon does not lose direction while it is tunneling. As it grows older, its body becomes increasingly rounder and smoother.",
        "vi":
            "Onix có một nam châm trong não của nó. Nó hoạt động như một chiếc la bàn để Pokémon này không bị mất phương hướng khi đào hầm. Khi lớn lên, cơ thể của nó ngày càng tròn và mượt mà"
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Phanpy",
      "imageURL": "assets/png/036.png",
      "HP": "90",
      "Attack": "60",
      "Defense": "60",
      "speed": "40",
      "spAtk": "40",
      "spDef": "40",
      "height": "1' 08",
      "weight": "73.9 lbs",
      "category": "Long Nose",
      "type": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "weaknesses": {
        "en": ["Grass", "Ice", "Water"],
        "vi": ["Cỏ", "Băng", "Nước"],
      },
      "introduction": {
        "en":
            "For its nest, Phanpy digs a vertical pit in the ground at the edge of a river. It marks the area around its nest with its trunk to let the others know that the area has been claimed.",
        "vi":
            "Đối với tổ của nó, Phanpy đào một cái hố thẳng đứng trong lòng đất ở rìa một con sông. Nó đánh dấu khu vực xung quanh tổ của mình bằng thân cây của mình để cho những người khác biết rằng khu vực đã được xác nhận quyền sở hữu."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Pikachu",
      "imageURL": "assets/png/037.png",
      "HP": "35",
      "Attack": "55",
      "Defense": "40",
      "speed": "90",
      "spAtk": "50",
      "spDef": "50",
      "height": "1' 04",
      "weight": "13.2 lbs",
      "category": "Mouse",
      "type": {
        "en": ["Electric"],
        "vi": ["Điện"],
      },
      "weaknesses": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "introduction": {
        "en":
            "Whenever Pikachu comes across something new, it blasts it with a jolt of electricity. If you come across a blackened berry, it's evidence that this Pokémon mistook the intensity of its charge.",
        "vi":
            "Bất cứ khi nào Pikachu gặp một thứ gì đó mới, nó sẽ thổi bay nó bằng một luồng điện. Nếu bạn bắt gặp một quả mọng bị đen, đó là bằng chứng cho thấy Pokémon này đã nhầm cường độ điện tích của nó."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Poliwhirl",
      "imageURL": "assets/png/039.png",
      "HP": "65",
      "Attack": "65",
      "Defense": "65",
      "speed": "90",
      "spAtk": "50",
      "spDef": "50",
      "height": "3' 03",
      "weight": "44.1 lbs",
      "category": "Tadpole",
      "type": {
        "en": ["Water"],
        "vi": ["Nước"],
      },
      "weaknesses": {
        "en": ["Electric", "Grass"],
        "vi": ["Điện", "Cỏ"],
      },
      "introduction": {
        "en":
            "The surface of Poliwhirl's body is always wet and slick with a slimy fluid. Because of this slippery covering, it can easily slip and slide out of the clutches of any enemy in battle.",
        "vi":
            "Bề mặt cơ thể Poliwhirl luôn ẩm ướt và loang ra một chất dịch nhầy nhụa. Do lớp phủ trơn này, nó có thể dễ dàng trượt và trượt ra khỏi nanh vuốt của bất kỳ kẻ thù nào trong trận chiến."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Psyduck",
      "imageURL": "assets/png/041.png",
      "HP": "50",
      "Attack": "52",
      "Defense": "48",
      "speed": "55",
      "spAtk": "65",
      "spDef": "50",
      "height": "2' 07",
      "weight": "43.2 lbs",
      "category": "Duck",
      "type": {
        "en": ["Water"],
        "vi": ["Nước"],
      },
      "weaknesses": {
        "en": ["Electric", "Grass"],
        "vi": ["Điện", "Cỏ"],
      },
      "introduction": {
        "en":
            "Psyduck uses a mysterious power. When it does so, this Pokémon generates brain waves that are supposedly only seen in sleepers. This discovery spurred controversy among scholars.",
        "vi":
            "Psyduck sử dụng một sức mạnh bí ẩn. Khi nó làm như vậy, Pokémon này tạo ra các sóng não được cho là chỉ thấy ở những người đang ngủ. Phát hiện này đã gây ra tranh cãi giữa các học giả."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Rattata",
      "imageURL": "assets/png/031.png",
      "HP": "30",
      "Attack": "56",
      "Defense": "35",
      "speed": "72",
      "spAtk": "25",
      "spDef": "35",
      "height": "1' 00",
      "weight": "7.7 lbs",
      "category": "Mouse",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "Rattata is cautious in the extreme. Even while it is asleep, it constantly listens by moving its ears around. It is not picky about where it lives—it will make its nest anywhere.",
        "vi":
            "Rattata rất thận trọng. Ngay cả khi đang ngủ, nó vẫn liên tục lắng nghe bằng cách di chuyển tai. Nó không kén chọn nơi sinh sống - nó sẽ làm tổ ở bất cứ đâu."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Roselia",
      "imageURL": "assets/png/042.png",
      "HP": "50",
      "Attack": "60",
      "Defense": "45",
      "speed": "65",
      "spAtk": "100",
      "spDef": "80",
      "height": "1' 00",
      "weight": "4.4 lbs",
      "category": "Thorn",
      "type": {
        "en": ["Grass", "Poison"],
        "vi": ["Cỏ", "Độc"],
      },
      "weaknesses": {
        "en": ["Fire", "Flying", "Ice", "Psychic"],
        "vi": ["Lửa", "Bay", "Băng", "Ngoại cảm"],
      },
      "introduction": {
        "en":
            "Roselia shoots sharp thorns as projectiles at any opponent that tries to steal the flowers on its arms. The aroma of this Pokémon brings serenity to living things.",
        "vi":
            "Roselia bắn những chiếc gai nhọn như đạn vào bất kỳ đối thủ nào cố gắng cướp những bông hoa trên cánh tay của nó. Hương thơm của Pokémon này mang lại sự thanh thản cho các sinh vật."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Sandshrew",
      "imageURL": "assets/png/043.png",
      "HP": "50",
      "Attack": "75",
      "Defense": "85",
      "speed": "40",
      "spAtk": "20",
      "spDef": "30",
      "height": "2' 00",
      "weight": "26.5 lbs",
      "category": "Mouse",
      "type": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "weaknesses": {
        "en": ["Grass", "Ice", "Water"],
        "vi": ["Cỏ", "Băng", "Nước"],
      },
      "introduction": {
        "en":
            "Sandshrew's body is configured to absorb water without waste, enabling it to survive in an arid desert. This Pokémon curls up to protect itself from its enemies.",
        "vi":
            "Cơ thể của Sandshrew được cấu hình để hấp thụ nước mà không có chất thải, giúp nó có thể sống sót trong sa mạc khô cằn. Pokémon này cuộn tròn để bảo vệ bản thân khỏi kẻ thù."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Seedot",
      "imageURL": "assets/png/044.png",
      "HP": "40",
      "Attack": "40",
      "Defense": "50",
      "speed": "30",
      "spAtk": "30",
      "spDef": "30",
      "height": "1' 08",
      "weight": "8.8 lbs",
      "category": "Acorn",
      "type": {
        "en": ["Grass"],
        "vi": ["Cỏ"],
      },
      "weaknesses": {
        "en": ["Bug", "Fire", "Flying", "Ice", "Poison"],
        "vi": ["Bọ", "Lửa", "Bay", "Băng", "Độc"],
      },
      "introduction": {
        "en":
            "Seedot attaches itself to a tree branch using the top of its head. It sucks moisture from the tree while hanging off the branch. The more water it drinks, the glossier this Pokémon's body becomes.",
        "vi":
            "Seedot tự bám vào cành cây bằng cách sử dụng đỉnh đầu của nó. Nó hút hơi ẩm từ cây khi treo khỏi cành. Nó càng uống nhiều nước, cơ thể Pokémon này càng trở nên bóng bẩy."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Sentret",
      "imageURL": "assets/png/045.png",
      "HP": "35",
      "Attack": "46",
      "Defense": "34",
      "speed": "20",
      "spAtk": "35",
      "spDef": "45",
      "height": "2' 07",
      "weight": "13.2 lbs",
      "category": "Scout",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "When Sentret sleeps, it does so while another stands guard. The sentry wakes the others at the first sign of danger. When this Pokémon becomes separated from its pack, it becomes incapable of sleep due to fear.",
        "vi":
            "Khi Sentret ngủ, nó sẽ làm như vậy trong khi một người khác đứng bảo vệ. Người lính canh đánh thức những người khác khi có dấu hiệu nguy hiểm đầu tiên. Khi Pokémon này bị tách khỏi bầy của nó, nó sẽ không thể ngủ được do sợ hãi."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Snorlax",
      "imageURL": "assets/png/046.png",
      "HP": "160",
      "Attack": "110",
      "Defense": "65",
      "speed": "30",
      "spAtk": "65",
      "spDef": "110",
      "height": "6' 11",
      "weight": "1014.1 lbs",
      "category": "Sleeping",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "Snorlax's typical day consists of nothing more than eating and sleeping. It is such a docile Pokémon that there are children who use its expansive belly as a place to play.",
        "vi":
            "Một ngày điển hình của Snorlax không có gì khác hơn là ăn và ngủ. Nó là một Pokémon ngoan ngoãn đến mức có những đứa trẻ sử dụng chiếc bụng phình to của nó làm nơi vui chơi."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "spheal",
      "imageURL": "assets/png/047.png",
      "HP": "70",
      "Attack": "40",
      "Defense": "50",
      "speed": "25",
      "spAtk": "55",
      "spDef": "50",
      "height": "2' 07",
      "weight": "87.1 lbs",
      "category": "Clap",
      "type": {
        "en": ["Ice", "Water"],
        "vi": ["Băng", "Nước"],
      },
      "weaknesses": {
        "en": ["Electric", "Fighting", "Grass", "Rock"],
        "vi": ["Điện", "Chiến đấu", "Cỏ", "Đá"],
      },
      "introduction": {
        "en":
            "spheal is much faster rolling than walking to get around. When groups of this Pokémon eat, they all clap at once to show their pleasure. Because of this, their mealtimes are noisy.",
        "vi":
            "spheal lăn nhanh hơn nhiều so với việc đi bộ để đi lại. Khi các nhóm Pokémon này ăn, tất cả chúng đều vỗ tay cùng một lúc để thể hiện sự vui mừng của mình. Vì vậy, giờ ăn của chúng rất ồn ào."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Staryu",
      "imageURL": "assets/png/049.png",
      "HP": "30",
      "Attack": "45",
      "Defense": "55",
      "speed": "85",
      "spAtk": "70",
      "spDef": "55",
      "height": "2' 07",
      "weight": "76.1 lbs",
      "category": "Star Shape",
      "type": {
        "en": ["Water"],
        "vi": ["Nước"],
      },
      "weaknesses": {
        "en": ["Electric", "Grass"],
        "vi": ["Điện", "Cỏ"],
      },
      "introduction": {
        "en":
            "Staryu's center section has an organ called the core that shines bright red. If you go to a beach toward the end of summer, the glowing cores of these Pokémon look like the stars in the sky.",
        "vi":
            "Phần trung tâm của Staryu có một cơ quan được gọi là lõi phát sáng màu đỏ. Nếu bạn đi đến một bãi biển vào cuối mùa hè, lõi phát sáng của những Pokémon này trông giống như những ngôi sao trên bầu trời."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Sudowoodo",
      "imageURL": "assets/png/050.png",
      "HP": "70",
      "Attack": "100",
      "Defense": "115",
      "speed": "30",
      "spAtk": "65",
      "spDef": "30",
      "height": "3' 11",
      "weight": "83.8 lbs",
      "category": "Imitation",
      "type": {
        "en": ["Rock"],
        "vi": ["Đá"],
      },
      "weaknesses": {
        "en": ["Fighting", "Grass", "Ground", "Steel", "Water"],
        "vi": ["Chiến đấu", "Cỏ", "Đất", "Thép", "Nước"],
      },
      "introduction": {
        "en":
            "Sudowoodo camouflages itself as a tree to avoid being attacked by enemies. However, because its hands remain green throughout the year, the Pokémon is easily identified as a fake during the winter.",
        "vi":
            "Sudowoodo ngụy trang thành một cái cây để tránh bị kẻ thù tấn công. Tuy nhiên, vì bàn tay của nó vẫn có màu xanh quanh năm nên Pokémon này dễ dàng bị xác định là giả trong suốt mùa đông."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Sunkern",
      "imageURL": "assets/png/051.png",
      "HP": "30",
      "Attack": "30",
      "Defense": "30",
      "speed": "30",
      "spAtk": "30",
      "spDef": "30",
      "height": "1' 00",
      "weight": "4.0 lbs",
      "category": "Seed",
      "type": {
        "en": ["Grass"],
        "vi": ["Cỏ"],
      },
      "weaknesses": {
        "en": ["Bug", "Fire", "Flying", "Ice", "Poison"],
        "vi": ["Bọ", "Lửa", "Bay", "Băng", "Độc"],
      },
      "introduction": {
        "en":
            "Sunkern tries to move as little as it possibly can. It does so because it tries to conserve all the nutrients it has stored in its body for its evolution. It will not eat a thing, subsisting only on morning dew.",
        "vi":
            "Sunkern cố gắng di chuyển ít nhất có thể. Nó làm như vậy bởi vì nó cố gắng bảo tồn tất cả các chất dinh dưỡng mà nó đã dự trữ trong cơ thể để phục vụ cho quá trình tiến hóa của nó. Nó sẽ không ăn bất cứ thứ gì, chỉ sống nhờ vào sương sớm."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Swablu",
      "imageURL": "assets/png/052.png",
      "HP": "45",
      "Attack": "40",
      "Defense": "60",
      "speed": "50",
      "spAtk": "40",
      "spDef": "75",
      "height": "1' 04",
      "weight": "2.6 lbs",
      "category": "Cotton Bird",
      "type": {
        "en": ["Flying", "Normal"],
        "vi": ["Bay", "Bình thường"],
      },
      "weaknesses": {
        "en": ["Electric", "Ice", "Rock"],
        "vi": ["Điện", "Băng", "Đá"],
      },
      "introduction": {
        "en":
            "Swablu has light and fluffy wings that are like cottony clouds. This Pokémon is not frightened of people. It lands on the heads of people and sits there like a cotton-fluff hat.",
        "vi":
            "Swablu có đôi cánh nhẹ và mịn giống như những đám mây bông. Pokémon này không sợ hãi con người. Nó đậu trên đầu người ta và ngồi đó như một chiếc mũ lông bông."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Swinub",
      "imageURL": "assets/png/053.png",
      "HP": "50",
      "Attack": "50",
      "Defense": "40",
      "speed": "50",
      "spAtk": "30",
      "spDef": "30",
      "height": "1' 04",
      "weight": "14.3 lbs",
      "category": "Pig",
      "type": {
        "en": ["Ice", "Ground"],
        "vi": ["Băng", "Đất"],
      },
      "weaknesses": {
        "en": ["Fighting", "Fire", "Grass", "Steel", "Water"],
        "vi": ["Chiến đấu", "Lửa", "Cỏ", "Thép", "Nước"],
      },
      "introduction": {
        "en":
            "Swinub roots for food by rubbing its snout against the ground. Its favorite food is a mushroom that grows under the cover of dead grass. This Pokémon occasionally roots out hot springs.",
        "vi":
            "Swinub bén rễ tìm thức ăn bằng cách cọ sát mõm của nó vào mặt đất. Thức ăn ưa thích của nó là nấm mọc dưới lớp cỏ. Pokémon này thỉnh thoảng bén rễ ra suối nước nóng."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Teddiursa",
      "imageURL": "assets/png/054.png",
      "HP": "60",
      "Attack": "80",
      "Defense": "50",
      "speed": "40",
      "spAtk": "50",
      "spDef": "50",
      "height": "2' 00",
      "weight": "19.4 lbs",
      "category": "Little Bear",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "This Pokémon likes to lick its palms that are sweetened by being soaked in honey. Teddiursa concocts its own honey by blending fruits and pollen collected by Beedrill.",
        "vi":
            "Pokémon này thích liếm lòng bàn tay ngọt ngào do được ngâm trong mật ong. Teddiursa tự pha chế mật ong bằng cách trộn hoa quả và phấn hoa do Beedrill thu thập."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Voltorb",
      "imageURL": "assets/png/056.png",
      "HP": "40",
      "Attack": "30",
      "Defense": "50",
      "speed": "100",
      "spAtk": "55",
      "spDef": "55",
      "height": "1' 08",
      "weight": "22.9 lbs",
      "category": "Ball",
      "type": {
        "en": ["Electric"],
        "vi": ["Điện"],
      },
      "weaknesses": {
        "en": ["Ground"],
        "vi": ["Đất"],
      },
      "introduction": {
        "en":
            "Voltorb was first sighted at a company that manufactures Poké Balls. The link between that sighting and the fact that this Pokémon looks very similar to a Poké Ball remains a mystery.",
        "vi":
            "Voltorb lần đầu tiên được nhìn thấy tại một công ty sản xuất Poké Balls. Mối liên hệ giữa việc nhìn thấy đó và thực tế là Pokémon này trông rất giống với Poké Ball vẫn còn là một bí ẩn."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Wailmer",
      "imageURL": "assets/png/057.png",
      "HP": "130",
      "Attack": "70",
      "Defense": "35",
      "speed": "60",
      "spAtk": "70",
      "spDef": "35",
      "height": "6' 07",
      "weight": "286.6 lbs",
      "category": "Ball Whale",
      "type": {
        "en": ["Water"],
        "vi": ["Nước"],
      },
      "weaknesses": {
        "en": ["Electric", "Grass"],
        "vi": ["Điện", "Cỏ"],
      },
      "introduction": {
        "en":
            "Wailmer's nostrils are located above its eyes. This playful Pokémon loves to startle people by forcefully snorting out seawater it stores inside its body out of its nostrils.",
        "vi":
            "Lỗ mũi của Wailmer nằm ở phía trên mắt của nó. Pokémon vui tươi này thích làm mọi người giật mình bằng cách mạnh mẽ khịt mũi ra nước biển mà nó tích trữ bên trong cơ thể của nó."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Whismur",
      "imageURL": "assets/png/058.png",
      "HP": "64",
      "Attack": "51",
      "Defense": "23",
      "speed": "28",
      "spAtk": "51",
      "spDef": "23",
      "height": "2' 00",
      "weight": "35.9 lbs",
      "category": "Whisper",
      "type": {
        "en": ["Normal"],
        "vi": ["Bình thường"],
      },
      "weaknesses": {
        "en": ["Fighting"],
        "vi": ["Chiến đấu"],
      },
      "introduction": {
        "en":
            "Normally, Whismur's voice is very quiet—it is barely audible even if one is paying close attention. However, if this Pokémon senses danger, it starts crying at an earsplitting volume.",
        "vi":
            "Thông thường, giọng nói của Whismur rất nhỏ - nó khó có thể nghe thấy ngay cả khi ai đó để ý kỹ. Tuy nhiên, nếu con Pokémon này cảm thấy nguy hiểm, nó sẽ bắt đầu khóc với âm lượng vừa tai."
      }
    },
  ),
  Pokemon.fromJson(
    {
      "name": "Wingull",
      "imageURL": "assets/png/059.png",
      "HP": "40",
      "Attack": "30",
      "Defense": "30",
      "speed": "85",
      "spAtk": "55",
      "spDef": "30",
      "height": "2' 00",
      "weight": "15.2 lbs",
      "category": "Seed",
      "type": {
        "en": ["Water", "Flying"],
        "vi": ["Nước", "Bay"],
      },
      "weaknesses": {
        "en": ["Electric", "Rock"],
        "vi": ["Điện", "Đá"],
      },
      "introduction": {
        "en":
            "Wingull has the Task of carrying prey and valuables in its beak and hiding them in all sorts of locations. This Pokémon rides the winds and flies as if it were skating across the sky.",
        "vi":
            "Wingull có nhiệm vụ mang con mồi và các vật có giá trị trong mỏ của nó và giấu chúng ở mọi vị trí. Pokémon này cưỡi gió và bay như thể nó đang trượt băng trên bầu trời."
      }
    },
  ),
  Pokemon.fromJson({
    "name": "Yanma",
    "imageURL": "assets/png/060.png",
    "HP": "65",
    "Attack": "65",
    "Defense": "45",
    "speed": "95",
    "spAtk": "75",
    "spDef": "45",
    "height": "3' 11",
    "weight": "83.8 lbs",
    "category": "Clear Wing",
    "type": {
      "en": ["Bug", "Flying"],
      "vi": ["Bọ", "Bay"],
    },
    "weaknesses": {
      "en": ["Rock", "Electric", "Fire", "Flying", "Ice"],
      "vi": ["Đá", "Điện", "Lửa", "Bay", "Băng"],
    },
    "introduction": {
      "en":
          "Yanma is capable of seeing 360 degrees without having to move its eyes. It is a great flier that is adept at making sudden stops and turning midair. This Pokémon uses its flying ability to quickly chase down targeted prey.",
      "vi":
          "Yanma có khả năng nhìn 360 độ mà không cần phải di chuyển mắt. Nó là một phi công cừ khôi có khả năng dừng lại đột ngột và quay đầu giữa không trung. Pokémon này sử dụng khả năng bay của mình để nhanh chóng truy đuổi con mồi mục tiêu."
    }
  }),
];
