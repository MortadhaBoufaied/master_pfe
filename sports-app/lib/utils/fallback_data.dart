import '../models/match.dart';

class FallbackData {
  static List<MatchModel> seededMatches() {
    return [
      MatchModel(
        id: 1,
        type: "MATCH",
        date: "2025-12-23",
        opponent: "Opponent 1",
        location: "Stadium 1",
        result: "LOSS",
        score: "1-2",
      ),
      MatchModel(
        id: 2,
        type: "MATCH",
        date: "2025-12-24",
        opponent: "Opponent 2",
        location: "Stadium 2",
        result: "WIN",
        score: "2-0",
      ),
      MatchModel(
        id: 3,
        type: "MATCH",
        date: "2025-12-25",
        opponent: "Opponent 3",
        location: "Stadium 3",
        result: "WIN",
        score: "3-1",
      ),
    ];
  }
}


