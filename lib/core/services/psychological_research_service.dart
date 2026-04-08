import 'package:research_package/research_package.dart';
import 'package:research_package/model.dart';

class PsychologicalResearchService {
  /// Defines the PHQ-9 (Patient Health Questionnaire-9) task
  static RPOrderedTask phq9Task() {
    final instructionStep = RPInstructionStep(
      identifier: 'phq9_instruction',
      title: 'Mood Assessment (PHQ-9)',
      detailText: 'Over the last 2 weeks, how often have you been bothered by any of the following problems?',
      footnote: 'This is a standard screening tool used by healthcare professionals.',
    );

    final choices = [
      RPChoice(text: 'Not at all', value: 0),
      RPChoice(text: 'Several days', value: 1),
      RPChoice(text: 'More than half the days', value: 2),
      RPChoice(text: 'Nearly every day', value: 3),
    ];

    final answerFormat = RPChoiceAnswerFormat(
      choices: choices,
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
    );

    final q1 = RPQuestionStep(
      identifier: 'q1',
      title: 'Little interest or pleasure in doing things',
      answerFormat: answerFormat,
    );

    final q2 = RPQuestionStep(
      identifier: 'q2',
      title: 'Feeling down, depressed, or hopeless',
      answerFormat: answerFormat,
    );

    final q3 = RPQuestionStep(
      identifier: 'q3',
      title: 'Trouble falling or staying asleep, or sleeping too much',
      answerFormat: answerFormat,
    );

    final q4 = RPQuestionStep(
      identifier: 'q4',
      title: 'Feeling tired or having little energy',
      answerFormat: answerFormat,
    );

    final q5 = RPQuestionStep(
      identifier: 'q5',
      title: 'Poor appetite or overeating',
      answerFormat: answerFormat,
    );

    final q6 = RPQuestionStep(
      identifier: 'q6',
      title: 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
      answerFormat: answerFormat,
    );

    final q7 = RPQuestionStep(
      identifier: 'q7',
      title: 'Trouble concentrating on things, such as reading the newspaper or watching television',
      answerFormat: answerFormat,
    );

    final q8 = RPQuestionStep(
      identifier: 'q8',
      title: 'Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
      answerFormat: answerFormat,
    );

    final q9 = RPQuestionStep(
      identifier: 'q9',
      title: 'Thoughts that you would be better off dead or of hurting yourself in some way',
      answerFormat: answerFormat,
    );

    final completionStep = RPCompletionStep(
      identifier: 'phq9_completion',
      title: 'Assessment Complete',
      text: 'Thank you for your honesty. We will now analyze your results.',
    );

    return RPOrderedTask(
      identifier: 'phq9_task',
      steps: [instructionStep, q1, q2, q3, q4, q5, q6, q7, q8, q9, completionStep],
    );
  }

  /// Defines the GAD-7 (Generalized Anxiety Disorder-7) task
  static RPOrderedTask gad7Task() {
    final choices = [
      RPChoice(text: 'Not at all', value: 0),
      RPChoice(text: 'Several days', value: 1),
      RPChoice(text: 'More than half the days', value: 2),
      RPChoice(text: 'Nearly every day', value: 3),
    ];

    final answerFormat = RPChoiceAnswerFormat(
      choices: choices,
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
    );

    final questions = [
      'Feeling nervous, anxious or on edge',
      'Not being able to stop or control worrying',
      'Worrying too much about different things',
      'Trouble relaxing',
      'Being so restless that it is hard to sit still',
      'Becoming easily annoyed or irritable',
      'Feeling afraid as if something awful might happen',
    ];

    final steps = [
      RPInstructionStep(
        identifier: 'gad7_instruction',
        title: 'Anxiety Scan (GAD-7)',
        detailText: 'Over the last 2 weeks, how often have you been bothered by the following problems?',
      ),
      ...questions.asMap().entries.map((e) => RPQuestionStep(
        identifier: 'q${e.key + 1}',
        title: e.value,
        answerFormat: answerFormat,
      )),
      RPCompletionStep(
        identifier: 'gad7_completion',
        title: 'Assessment Complete',
        text: 'Your progress is saved.',
      ),
    ];

    return RPOrderedTask(identifier: 'gad7_task', steps: steps);
  }

  /// Defines the PSS-10 (Perceived Stress Scale) task
  static RPOrderedTask pss10Task() {
    final choices = [
      RPChoice(text: 'Never', value: 0),
      RPChoice(text: 'Almost Never', value: 1),
      RPChoice(text: 'Sometimes', value: 2),
      RPChoice(text: 'Fairly Often', value: 3),
      RPChoice(text: 'Very Often', value: 4),
    ];

    final answerFormat = RPChoiceAnswerFormat(
      choices: choices,
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
    );

    final questions = [
      'In the last month, how often have you been upset because of something that happened unexpectedly?',
      'In the last month, how often have you felt that you were unable to control the important things in your life?',
      'In the last month, how often have you felt nervous and "stressed"?',
      'In the last month, how often have you felt confident about your ability to handle your personal problems?',
      'In the last month, how often have you felt that things were going your way?',
      'In the last month, how often have you found that you could not cope with all the things that you had to do?',
      'In the last month, how often have you been able to control irritations in your life?',
      'In the last month, how often have you felt that you were on top of things?',
      'In the last month, how often have you been angered because of things that were outside of your control?',
      'In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?',
    ];

    final steps = [
      RPInstructionStep(
        identifier: 'pss10_instruction',
        title: 'Stress Level (PSS-10)',
        detailText: 'The following questions ask you about your feelings and thoughts during the last month.',
      ),
      ...questions.asMap().entries.map((e) => RPQuestionStep(
        identifier: 'q${e.key + 1}',
        title: e.value,
        answerFormat: answerFormat,
      )),
      RPCompletionStep(
        identifier: 'pss10_completion',
        title: 'Assessment Complete',
        text: 'Thank you for completing the stress assessment.',
      ),
    ];

    return RPOrderedTask(identifier: 'pss10_task', steps: steps);
  }
}
