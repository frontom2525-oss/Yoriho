# -*- coding: utf-8 -*-
import asyncio
import random
import string
import json
import os
from datetime import datetime, timedelta

from aiogram import Bot, Dispatcher, F
from aiogram.types import Message, InlineKeyboardMarkup, InlineKeyboardButton, CallbackQuery
from aiogram.filters import CommandStart, Command

# ============================================
# НАСТРОЙКИ
# ============================================
BOT_TOKEN = "8960290014:AAGdLLqzwgJnEv8UPB_UEyV0qbqcww38Trw"
CHANNEL_ID = "@stealeggstockyoriho"
DB_FILE = "keys_db.json"
TOTAL_KEYS = 10000

VIP_KEYS = [
    "YORIHO-VIP-OWNER",
    "YORIHO-VIP-ADMIN",
    "YORIHO-VIP-TESTER",
]

# ============================================
# ГЕНЕРАЦИЯ
# ============================================
def generate_key():
    b1 = "X" + "".join(random.choices(string.digits, k=3))
    b2 = "X" + "".join(random.choices(string.digits, k=3))
    return f"YORIHO-{b1}-{b2}"

def load_db():
    if not os.path.exists(DB_FILE):
        return {}
    with open(DB_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_db(db):
    with open(DB_FILE, "w", encoding="utf-8") as f:
        json.dump(db, f, indent=2)

def generate_all_keys():
    print(f"[+] Генерируем {TOTAL_KEYS} ключей...")
    db = load_db()
    now = datetime.now()
    expire = now + timedelta(days=1)

    count = 0
    while count < TOTAL_KEYS:
        key = generate_key()
        if key not in db:
            db[key] = {
                "type": "regular",
                "created": now.isoformat(),
                "expires": expire.isoformat(),
                "used": False,
            }
            count += 1
            if count % 1000 == 0:
                print(f"    Сгенерировано: {count}")

    for vip in VIP_KEYS:
        db[vip] = {
            "type": "vip",
            "created": now.isoformat(),
            "expires": "never",
            "used": False,
        }

    save_db(db)
    print(f"[+] Готово! {len(db)} ключей")
    return db

# ============================================
# BOT
# ============================================
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

async def check_subscription(user_id):
    try:
        member = await bot.get_chat_member(chat_id=CHANNEL_ID, user_id=user_id)
        print(f"[DEBUG] User {user_id} status: {member.status}")
        return member.status in ["member", "administrator", "creator"]
    except Exception as e:
        print(f"[!] Ошибка проверки: {e}")
        return False

def get_sub_keyboard():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="📢 Подписаться", url="https://t.me/stealeggstockyoriho")],
        [InlineKeyboardButton(text="✅ Я подписался", callback_data="check_sub")]
    ])

@dp.message(CommandStart())
async def cmd_start(message: Message):
    await message.answer(
        "👋 Yoriho Key Bot\n\n"
        f"Подпишись на канал: {CHANNEL_ID}\n"
        "Потом нажми «Я подписался».",
        reply_markup=get_sub_keyboard()
    )

@dp.callback_query(F.data == "check_sub")
async def callback_check(callback: CallbackQuery):
    user_id = callback.from_user.id

    if not await check_subscription(user_id):
        await callback.answer("❌ Ты не подписан!", show_alert=True)
        return

    await callback.answer("✅ Подписка подтверждена!")

    db = load_db()
    regular = [k for k, v in db.items()
               if v.get("type") == "regular" and not v.get("used")]

    if not regular:
        await callback.message.answer("❌ Свободных ключей нет.")
        return

    key = random.choice(regular)
    db[key]["used"] = True
    save_db(db)

    expires = datetime.fromisoformat(db[key]["expires"])
    await callback.message.answer(
        f"🔑 Твой ключ:\n\n`{key}`\n\n"
        f"⏰ Срок: 1 день (до {expires.strftime('%d.%m %H:%M')})\n\n"
        f"Скопируй и вставь в скрипт.",
        parse_mode="Markdown"
    )

@dp.message(Command("getkey"))
async def cmd_getkey(message: Message):
    user_id = message.from_user.id

    if not await check_subscription(user_id):
        await message.answer("❌ Подпишись на канал!", reply_markup=get_sub_keyboard())
        return

    db = load_db()
    regular = [k for k, v in db.items()
               if v.get("type") == "regular" and not v.get("used")]

    if not regular:
        await message.answer("❌ Свободных ключей нет.")
        return

    key = random.choice(regular)
    db[key]["used"] = True
    save_db(db)

    await message.answer(
        f"🔑 Твой ключ:\n\n`{key}`\n\n⏰ Срок: 1 день",
        parse_mode="Markdown"
    )

@dp.message(Command("debug"))
async def cmd_debug(message: Message):
    user_id = message.from_user.id
    try:
        member = await bot.get_chat_member(chat_id=CHANNEL_ID, user_id=user_id)
        await message.answer(
            f"🔍 Отладка:\n\n"
            f"Твой ID: `{user_id}`\n"
            f"Канал: `{CHANNEL_ID}`\n"
            f"Статус: `{member.status}`\n"
            f"Подписан: `{member.status in ['member', 'administrator', 'creator']}`",
            parse_mode="Markdown"
        )
    except Exception as e:
        await message.answer(f"❌ Ошибка: `{e}`", parse_mode="Markdown")

@dp.message(Command("vip"))
async def cmd_vip(message: Message):
    ADMIN_ID = 123456789  # ← ТВОЙ Telegram ID
    if message.from_user.id != ADMIN_ID:
        await message.answer("❌ Нет доступа.")
        return
    key = random.choice(VIP_KEYS)
    await message.answer(f"👑 VIP-ключ:\n\n`{key}`", parse_mode="Markdown")

@dp.message(Command("stats"))
async def cmd_stats(message: Message):
    db = load_db()
    regular = sum(1 for v in db.values() if v.get("type") == "regular")
    vip = sum(1 for v in db.values() if v.get("type") == "vip")
    used = sum(1 for v in db.values() if v.get("used"))
    await message.answer(
        f"📊 Статистика:\n\n"
        f"Обычных: {regular}\n"
        f"VIP: {vip}\n"
        f"Использовано: {used}"
    )

# ============================================
# ЗАПУСК
# ============================================
async def main():
    if not os.path.exists(DB_FILE):
        print("[!] Генерируем базу...")
        generate_all_keys()
    else:
        db = load_db()
        print(f"[+] База: {len(db)} ключей")

    print("[+] Бот запущен...")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
