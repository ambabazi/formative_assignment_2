class SkillMatcher {
  static double calculateMatch({
    required List<String> studentSkills,
    required List<String> requiredSkills,
  }) {
    if (requiredSkills.isEmpty) return 0;

    int matched = 0;

    for (final required in requiredSkills) {
      final found = studentSkills.any(
        (skill) => skill.toLowerCase() == required.toLowerCase(),
      );
      if (found) matched++;
    }

    return matched / requiredSkills.length;
  }
}
