#!/bin/bash
# Generate tutor greeting audio files using ElevenLabs TTS API
# Usage: source ~/.zshrc && bash scripts/generate-greetings.sh

set -e

API_KEY="${ELEVEN_LABS_API_KEY:?Set ELEVEN_LABS_API_KEY}"
MODEL="eleven_flash_v2_5"
OUT_DIR="assets/audio/greetings"
mkdir -p "$OUT_DIR"

generate() {
  local name="$1" voice_id="$2" idx="$3" text="$4"
  local file="${OUT_DIR}/${name}_${idx}.mp3"

  if [ -f "$file" ]; then
    echo "  SKIP $file (exists)"
    return
  fi

  echo "  GEN  $file"
  curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/${voice_id}" \
    -H "xi-api-key: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -o "$file" \
    -d "{
      \"text\": \"${text}\",
      \"model_id\": \"${MODEL}\",
      \"voice_settings\": {
        \"stability\": 0.4,
        \"similarity_boost\": 0.8,
        \"style\": 0.6
      }
    }"

  # Check if valid audio (not error JSON)
  if file "$file" | grep -q "JSON\|ASCII\|text"; then
    echo "  ERR  $file — API error:"
    cat "$file"
    rm "$file"
    return 1
  fi
}

echo "=== Luna (Spanish) ==="
VOICE="EXAVITQu4vr4xnSDxMaL"
generate luna $VOICE 1 "Hola! Soy Luna, tu profesora de espanol. Vamos a practicar juntos!"
generate luna $VOICE 2 "Hola hola! Que tal? Lista para hablar en espanol?"
generate luna $VOICE 3 "Buenos dias! Soy Luna. Hoy vamos a pasarlo genial aprendiendo espanol."
generate luna $VOICE 4 "Hola! Me alegro de verte. Quieres empezar una conversacion?"
generate luna $VOICE 5 "Ey! Soy Luna. Vamos, animate a hablar conmigo!"

echo "=== Alfie (English) ==="
VOICE="pNInz6obpgDQGcFmaJgB"
generate alfie $VOICE 1 "Hey there! I'm Alfie, your English tutor. Ready to chat?"
generate alfie $VOICE 2 "Hi! Nice to meet you. Let's practice some English together!"
generate alfie $VOICE 3 "Hello! I'm Alfie. Don't worry about mistakes, that's how we learn!"
generate alfie $VOICE 4 "Hey! Fancy a conversation in English? I'm all ears!"
generate alfie $VOICE 5 "What's up! I'm Alfie. Let's get talking!"

echo "=== Elsa (German) ==="
VOICE="21m00Tcm4TlvDq8ikWAM"
generate elsa $VOICE 1 "Hallo! Ich bin Elsa, deine Deutschlehrerin. Lass uns anfangen!"
generate elsa $VOICE 2 "Hi! Schon dich zu sehen. Bist du bereit, Deutsch zu uben?"
generate elsa $VOICE 3 "Guten Tag! Ich bin Elsa. Zusammen schaffen wir das!"
generate elsa $VOICE 4 "Hallo! Keine Sorge, ich helfe dir bei jedem Schritt."
generate elsa $VOICE 5 "Hey! Ich bin Elsa. Auf geht's, lass uns Deutsch sprechen!"

echo "=== Kasia (Polish) ==="
VOICE="AZnzlk1XvdvUeBnXmlld"
generate kasia $VOICE 1 "Czesc! Jestem Kasia, twoja nauczycielka polskiego. Zaczynamy?"
generate kasia $VOICE 2 "Hej! Milo cie widziec. Pogadajmy po polsku!"
generate kasia $VOICE 3 "Czesc! Jestem Kasia. Nie martw sie o bledy, najwazniejsze to mowic!"
generate kasia $VOICE 4 "Siema! Gotowy na rozmowe po polsku? Bedzie super!"
generate kasia $VOICE 5 "Hej hej! Jestem Kasia. Dawaj, porozmawiajmy!"

echo "=== Emile (French) ==="
VOICE="VR6AewLTigWG4xSOukaG"
generate emile $VOICE 1 "Bonjour! Je suis Emile, votre professeur de francais. On commence?"
generate emile $VOICE 2 "Salut! Ravi de vous rencontrer. Parlons francais ensemble!"
generate emile $VOICE 3 "Bonjour! Je suis Emile. N'ayez pas peur de faire des erreurs!"
generate emile $VOICE 4 "Coucou! Je suis Emile. Pret pour une conversation en francais?"
generate emile $VOICE 5 "Salut! On va bien s'amuser a parler francais. Allons-y!"

echo "=== Sofia (Italian) ==="
VOICE="XB0fDUnXU5powFXDhCwa"
generate sofia $VOICE 1 "Ciao! Sono Sofia, la tua insegnante di italiano. Iniziamo!"
generate sofia $VOICE 2 "Ciao ciao! Come stai? Parliamo un po' in italiano!"
generate sofia $VOICE 3 "Buongiorno! Sono Sofia. Oggi impariamo qualcosa di bello!"
generate sofia $VOICE 4 "Ciao! Sono Sofia. Non preoccuparti degli errori, sbagliando si impara!"
generate sofia $VOICE 5 "Ehi! Sono Sofia. Dai, facciamo una bella chiacchierata!"

echo "=== Mateo (Portuguese) ==="
VOICE="TxGEqnHWrfWFTfGW9XjX"
generate mateo $VOICE 1 "Ola! Eu sou o Mateo, seu professor de portugues. Vamos comecar?"
generate mateo $VOICE 2 "E ai! Bom te ver aqui. Bora praticar portugues!"
generate mateo $VOICE 3 "Ola! Sou o Mateo. Nao se preocupe com erros, o importante e falar!"
generate mateo $VOICE 4 "Fala! Sou o Mateo. Pronto pra bater um papo em portugues?"
generate mateo $VOICE 5 "Oi! Sou o Mateo. Vamos nessa, vai ser legal!"

echo "=== Yuki (Japanese) ==="
VOICE="MF3mGyEYCl7XYWbV9V6O"
generate yuki $VOICE 1 "こんにちは！ユキです。一緒に日本語を練習しましょう！"
generate yuki $VOICE 2 "やあ！ユキだよ。日本語で話そう！"
generate yuki $VOICE 3 "こんにちは！ユキです。間違いを気にしないで、楽しく学ぼう！"
generate yuki $VOICE 4 "はじめまして！ユキです。日本語の会話、始めましょう！"
generate yuki $VOICE 5 "こんにちは！今日も一緒に頑張ろうね！"

echo "=== Mina (Korean) ==="
VOICE="z9fAnlkpzviPz146aGWa"
generate mina $VOICE 1 "안녕하세요! 미나예요. 같이 한국어를 연습해요!"
generate mina $VOICE 2 "안녕! 미나야. 한국어로 이야기하자!"
generate mina $VOICE 3 "안녕하세요! 실수해도 괜찮아요. 같이 배워요!"
generate mina $VOICE 4 "반가워요! 미나예요. 한국어 대화 시작할까요?"
generate mina $VOICE 5 "안녕! 오늘도 같이 열심히 해요!"

echo "=== Wei (Chinese) ==="
VOICE="ErXwobaYiN019PkySvjV"
generate wei $VOICE 1 "你好！我是小威。我们一起练习中文吧！"
generate wei $VOICE 2 "嗨！我是小威。来聊聊天吧！"
generate wei $VOICE 3 "你好！别担心说错，最重要的是开口说！"
generate wei $VOICE 4 "大家好！我是小威。准备好说中文了吗？"
generate wei $VOICE 5 "嘿！我是小威。今天我们一起加油！"

echo ""
echo "Done! Generated files:"
ls -lh "$OUT_DIR"/ | tail -n +2
echo ""
echo "Total: $(ls "$OUT_DIR"/*.mp3 2>/dev/null | wc -l | tr -d ' ') files"
