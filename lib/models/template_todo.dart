import 'dart:convert';

import 'package:gottask/models/model.dart';
import 'package:gottask/utils/utils.dart';

class MultiLang<T> {
  final T vi;
  final T en;

  MultiLang({this.vi, this.en});
}

class TemplateTodo {
  final MultiLang<String> name;
  final MultiLang<String> note;
  final int color;
  final List<bool> categoryItems;
  final PriorityState priorityState;

  const TemplateTodo(this.name,
      {this.note, this.color, this.categoryItems, this.priorityState});
}

class TemplateTodoImpl {
  static TemplateTodo homework = TemplateTodo(
    MultiLang<String>(en: "Homework", vi: "Bài tập về nhà"),
    priorityState: PriorityState.High,
    categoryItems: List.generate(catagories.length, (index) => false)
      ..[2] = true,
    note: MultiLang<String>(
      en: jsonEncode([
        {"insert": "Subject ...:"},
        {
          "insert": "\n",
          "attributes": {"heading": 1}
        },
        {"insert": "Time to do homework:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2, "block": "ul"}
        },
        {"insert": "Start at:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Time:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Context:"},
        {
          "insert": "\n",
          "attributes": {"block": "ul", "heading": 2}
        },
        {"insert": "Homework:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Review again:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Summary:"},
        {
          "insert": "\n",
          "attributes": {"block": "ul", "heading": 2}
        },
        {"insert": "Completed:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Unfinished:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        }
      ]),
      vi: jsonEncode([
        {"insert": "Môn học ...:"},
        {
          "insert": "\n",
          "attributes": {"heading": 1}
        },
        {"insert": "Thời gian làm bài:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2, "block": "ul"}
        },
        {"insert": "Bắt đầu từ:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Thời gian:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Nội dung bài tập:"},
        {
          "insert": "\n",
          "attributes": {"block": "ul", "heading": 2}
        },
        {"insert": "Bài tập:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Ôn tập lại:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Tổng kết bài:"},
        {
          "insert": "\n",
          "attributes": {"block": "ul", "heading": 2}
        },
        {"insert": "Đã hoàn thành:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        },
        {"insert": "Chưa hoàn thành:"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        }
      ]),
    ),
  );
  static TemplateTodo playPlan = TemplateTodo(
    MultiLang<String>(en: "Plan to go out", vi: "Kế hoạch đi chơi"),
    categoryItems: List.generate(catagories.length, (index) => false)
      ..[5] = true
      ..[6] = true
      ..[8] = true,
    priorityState: PriorityState.High,
    note: MultiLang<String>(
      en: jsonEncode([
        {"insert": "Picnic plan:"},
        {
          "insert": "\n",
          "attributes": {"heading": 1}
        },
        {"insert": "Member:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "Place:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Items need to be prepared:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "Food, drinks: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Utensils necessary: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Boardgame, game: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Expense:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "Total revenue: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Total expenditure: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        }
      ]),
      vi: jsonEncode([
        {"insert": "Kế hoạch dã ngoại:"},
        {
          "insert": "\n",
          "attributes": {"heading": 1}
        },
        {"insert": "Thành viên:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        },
        {"insert": "Địa điểm:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Đồ cần chuẩn bị:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "Đồ ăn, đồ uống: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Đồ dùng cần thiết: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Trò chơi: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Kinh phí:"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        },
        {"insert": "Tổng thu: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        },
        {"insert": "Tổng chi: ..."},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        }
      ]),
    ),
  );

  static List<TemplateTodo> values = [homework, playPlan];
}
