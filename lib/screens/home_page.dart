import 'package:chatgpt_app/Widgets/feature_box.dart';
import 'package:chatgpt_app/constants/colors.dart';
import 'package:chatgpt_app/constants/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = '';

  String? generatedContent;
  String? generatedImageUrl;
  final delay = 200;
  final start = 200;

  final OpenAIService openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cybria'),
        centerTitle: true,
        leading: const Icon(Icons.menu),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 83,
                    width: 83,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/images/assistant.png'))),
                  ),
                ),
              ],
            ), //For the aSSITANT iMAGE

            //For The Bubble
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                  borderRadius:
                      BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? 'Hello User, Tell me how can i help you today :)'
                        : generatedContent!,
                    // generatedContent == null
                    //     ? 'Hello User, Tell me how can i help you today :)'
                    //     : generatedContent!,
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      fontSize: generatedContent == null ? 17 : 14,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   margin: const EdgeInsets.only(top: 10, left: 22),
            //   child: const Text(
            //     'ChatGPT may produce inaccurate information about people, places, or facts',
            //     style: TextStyle(
            //       color: Pallete.mainFontColor,
            //       fontFamily: 'Cera Pro',
            //       fontSize: 15,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                  borderRadius:
                      BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'ChatGPT may produce inaccurate information about people, places, or facts :)',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      fontSize: 17,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
              ),
            ),
            //List For Displaying The Features..
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: generatedContent == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText:
                        'Got assists in tasks, answers questions, and provides information promptly.',
                  ),
                  //For 2nd Box
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText:
                        'Dall-E generates imaginative and unique visual content for various purposes.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {});
            } else {
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {});
              await systemSpeak(speech);
            }
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
