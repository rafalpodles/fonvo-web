#!/usr/bin/env python3
"""Generate tutor greeting audio files using ElevenLabs TTS API."""

import os, json, subprocess, sys
from pathlib import Path

API_KEY = os.environ.get("ELEVEN_LABS_API_KEY")
if not API_KEY:
    print("Error: Set ELEVEN_LABS_API_KEY"); sys.exit(1)

MODEL = "eleven_flash_v2_5"
OUT_DIR = Path("assets/audio/greetings")
OUT_DIR.mkdir(parents=True, exist_ok=True)

TUTORS = {
    "luna": {
        "voice": "EXAVITQu4vr4xnSDxMaL",
        "greetings": [
            "¡Hola! Soy Luna, tu profesora de español. ¡Vamos a practicar juntos!",
            "¡Hola hola! ¿Qué tal? ¿Lista para hablar en español?",
            "¡Buenos días! Soy Luna. Hoy vamos a pasarlo genial aprendiendo español.",
            "¡Hola! Me alegro de verte. ¿Quieres empezar una conversación?",
            "¡Ey! Soy Luna. ¡Vamos, anímate a hablar conmigo!",
        ],
    },
    "alfie": {
        "voice": "pNInz6obpgDQGcFmaJgB",
        "greetings": [
            "Hey there! I'm Alfie, your English tutor. Ready to chat?",
            "Hi! Nice to meet you. Let's practice some English together!",
            "Hello! I'm Alfie. Don't worry about mistakes, that's how we learn!",
            "Hey! Fancy a conversation in English? I'm all ears!",
            "What's up! I'm Alfie. Let's get talking!",
        ],
    },
    "elsa": {
        "voice": "21m00Tcm4TlvDq8ikWAM",
        "greetings": [
            "Hallo! Ich bin Elsa, deine Deutschlehrerin. Lass uns anfangen!",
            "Hi! Schön dich zu sehen. Bist du bereit, Deutsch zu üben?",
            "Guten Tag! Ich bin Elsa. Zusammen schaffen wir das!",
            "Hallo! Keine Sorge, ich helfe dir bei jedem Schritt.",
            "Hey! Ich bin Elsa. Auf geht's, lass uns Deutsch sprechen!",
        ],
    },
    "kasia": {
        "voice": "AZnzlk1XvdvUeBnXmlld",
        "greetings": [
            "Cześć! Jestem Kasia, twoja nauczycielka polskiego. Zaczynamy?",
            "Hej! Miło cię widzieć. Pogadajmy po polsku!",
            "Cześć! Jestem Kasia. Nie martw się o błędy, najważniejsze to mówić!",
            "Siema! Gotowy na rozmowę po polsku? Będzie super!",
            "Hej hej! Jestem Kasia. Dawaj, porozmawiajmy!",
        ],
    },
    "emile": {
        "voice": "VR6AewLTigWG4xSOukaG",
        "greetings": [
            "Bonjour ! Je suis Émile, votre professeur de français. On commence ?",
            "Salut ! Ravi de vous rencontrer. Parlons français ensemble !",
            "Bonjour ! Je suis Émile. N'ayez pas peur de faire des erreurs !",
            "Coucou ! Je suis Émile. Prêt pour une conversation en français ?",
            "Salut ! On va bien s'amuser à parler français. Allons-y !",
        ],
    },
    "sofia": {
        "voice": "XB0fDUnXU5powFXDhCwa",
        "greetings": [
            "Ciao! Sono Sofia, la tua insegnante di italiano. Iniziamo!",
            "Ciao ciao! Come stai? Parliamo un po' in italiano!",
            "Buongiorno! Sono Sofia. Oggi impariamo qualcosa di bello!",
            "Ciao! Sono Sofia. Non preoccuparti degli errori, sbagliando si impara!",
            "Ehi! Sono Sofia. Dai, facciamo una bella chiacchierata!",
        ],
    },
    "mateo": {
        "voice": "TxGEqnHWrfWFTfGW9XjX",
        "greetings": [
            "Olá! Eu sou o Mateo, seu professor de português. Vamos começar?",
            "E aí! Bom te ver aqui. Bora praticar português!",
            "Olá! Sou o Mateo. Não se preocupe com erros, o importante é falar!",
            "Fala! Sou o Mateo. Pronto pra bater um papo em português?",
            "Oi! Sou o Mateo. Vamos nessa, vai ser legal!",
        ],
    },
    "yuki": {
        "voice": "MF3mGyEYCl7XYWbV9V6O",
        "greetings": [
            "こんにちは！ユキです。一緒に日本語を練習しましょう！",
            "やあ！ユキだよ。日本語で話そう！",
            "こんにちは！ユキです。間違いを気にしないで、楽しく学ぼう！",
            "はじめまして！ユキです。日本語の会話、始めましょう！",
            "こんにちは！今日も一緒に頑張ろうね！",
        ],
    },
    "mina": {
        "voice": "z9fAnlkpzviPz146aGWa",
        "greetings": [
            "안녕하세요! 미나예요. 같이 한국어를 연습해요!",
            "안녕! 미나야. 한국어로 이야기하자!",
            "안녕하세요! 실수해도 괜찮아요. 같이 배워요!",
            "반가워요! 미나예요. 한국어 대화 시작할까요?",
            "안녕! 오늘도 같이 열심히 해요!",
        ],
    },
    "wei": {
        "voice": "ErXwobaYiN019PkySvjV",
        "greetings": [
            "你好！我是小威。我们一起练习中文吧！",
            "嗨！我是小威。来聊聊天吧！",
            "你好！别担心说错，最重要的是开口说！",
            "大家好！我是小威。准备好说中文了吗？",
            "嘿！我是小威。今天我们一起加油！",
        ],
    },
}


def generate(name, voice_id, idx, text):
    path = OUT_DIR / f"{name}_{idx}.mp3"
    if path.exists():
        print(f"  SKIP {path}")
        return

    print(f"  GEN  {path}")
    payload = json.dumps({
        "text": text,
        "model_id": MODEL,
        "voice_settings": {
            "stability": 0.4,
            "similarity_boost": 0.8,
            "style": 0.6,
        },
    }, ensure_ascii=False)

    result = subprocess.run(
        [
            "curl", "-s", "-X", "POST",
            f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
            "-H", f"xi-api-key: {API_KEY}",
            "-H", "Content-Type: application/json",
            "-o", str(path),
            "-d", payload,
        ],
        capture_output=True,
    )

    # Check if result is audio or error
    with open(path, "rb") as f:
        head = f.read(16)
    if b"{" in head or b"detail" in head:
        print(f"  ERR  {path}:")
        print(path.read_text())
        path.unlink()


for name, data in TUTORS.items():
    print(f"=== {name.capitalize()} ===")
    for i, greeting in enumerate(data["greetings"], 1):
        generate(name, data["voice"], i, greeting)

print(f"\nDone! {len(list(OUT_DIR.glob('*.mp3')))} files generated.")
