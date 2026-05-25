import json
import random
from datetime import date, datetime, timedelta
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_FILES = [
    ROOT / "sports_management_project" / "seed.prepared.json",
    ROOT / "ressources" / "files" / "Data" / "data.json",
    ROOT / "sports_management_project" / "src" / "main" / "resources" / "Files" / "Data" / "data.json",
]
RNG = random.Random(20260517)
TODAY = date(2026, 5, 17)
PLAYERS_PER_DIVISION_MIN = 28
PLAYERS_PER_DIVISION_MAX = 44
ACADEMY_NOTIFICATIONS_PER_SPORT = 6


SPORTS = {
    "football": {
        "name": "Football",
        "divisions": ["U9", "U11", "U13", "U15", "U17", "U19"],
        "positions": ["Goalkeeper", "Defender", "Midfielder", "Winger", "Forward"],
        "theme": {
            "primaryColor": "#0f8a4b",
            "secondaryColor": "#f4c430",
            "backgroundColor": "#eefaf3",
            "accentColor": "#d62828",
            "textColor": "#102017",
            "cardStyle": "grass-card",
            "iconStyle": "field-line",
        },
    },
    "basketball": {
        "name": "Basketball",
        "divisions": ["U10", "U12", "U14", "U16", "U18", "Senior"],
        "positions": ["Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center"],
        "theme": {
            "primaryColor": "#c2410c",
            "secondaryColor": "#111827",
            "backgroundColor": "#fff7ed",
            "accentColor": "#f97316",
            "textColor": "#1f2937",
            "cardStyle": "court-card",
            "iconStyle": "hoop-line",
        },
    },
    "handball": {
        "name": "Handball",
        "divisions": ["U11", "U13", "U15", "U17", "U19", "Senior"],
        "positions": ["Goalkeeper", "Left Wing", "Right Wing", "Center Back", "Pivot"],
        "theme": {
            "primaryColor": "#1d4ed8",
            "secondaryColor": "#facc15",
            "backgroundColor": "#eff6ff",
            "accentColor": "#dc2626",
            "textColor": "#172554",
            "cardStyle": "arena-card",
            "iconStyle": "goal-line",
        },
    },
    "volleyball": {
        "name": "Volleyball",
        "divisions": ["U13", "U15", "U17", "U19", "Senior"],
        "positions": ["Setter", "Outside Hitter", "Opposite", "Middle Blocker", "Libero"],
        "theme": {
            "primaryColor": "#0891b2",
            "secondaryColor": "#f59e0b",
            "backgroundColor": "#ecfeff",
            "accentColor": "#10b981",
            "textColor": "#083344",
            "cardStyle": "net-card",
            "iconStyle": "serve-line",
        },
    },
    "tennis": {
        "name": "Tennis",
        "divisions": ["Red Ball", "Orange Ball", "Green Ball", "U12", "U14", "U16", "U18"],
        "positions": ["Singles", "Doubles", "Baseline", "Serve Volley", "All Court"],
        "theme": {
            "primaryColor": "#65a30d",
            "secondaryColor": "#0f172a",
            "backgroundColor": "#f7fee7",
            "accentColor": "#eab308",
            "textColor": "#1a2e05",
            "cardStyle": "court-card",
            "iconStyle": "racket-line",
        },
    },
}

ACADEMY_NAMES = [
    "Atlas", "Carthage", "Medina", "Sahel", "Ariana", "Cap Bon", "Jasmine", "Olympic", "Phoenix", "Victory"
]
CITIES = ["Tunis", "Sfax", "Sousse", "Bizerte", "Nabeul", "Monastir", "Ariana", "Kairouan", "Gabes", "Mahdia"]
FIRST_NAMES = [
    "Youssef", "Adam", "Amir", "Mehdi", "Rayen", "Ilyes", "Nour", "Sami", "Malek", "Anis",
    "Maya", "Lina", "Ines", "Rim", "Sarra", "Yasmine", "Farah", "Amira", "Nesrine", "Dina",
]
LAST_NAMES = [
    "Ben Ali", "Trabelsi", "Mansouri", "Haddad", "Bouzid", "Kammoun", "Jaziri", "Gharbi", "Chebbi", "Mbarek",
    "Sassi", "Hamdi", "Ayari", "Kefi", "Mokhtar", "Mejri", "Dridi", "Feki", "Toumi", "Saidi",
]
OFFER_CODES = [
    "REGULAR_MONTHLY", "REGULAR_QUARTERLY", "REGULAR_SEMIANNUAL", "REGULAR_YEARLY",
    "PRO_MONTHLY", "PRO_QUARTERLY", "PRO_SEMIANNUAL", "PRO_YEARLY",
]


def slugify(value):
    return (
        value.lower()
        .replace(" ", "-")
        .replace("'", "")
        .replace("/", "-")
        .replace("--", "-")
    )


def iso(value):
    if isinstance(value, datetime):
        return value.replace(microsecond=0).isoformat()
    return value.isoformat()


def full_name():
    return f"{RNG.choice(FIRST_NAMES)} {RNG.choice(LAST_NAMES)}"


def email(local, domain="seed.sports.local"):
    return f"{slugify(local)}@{domain}"


def offer_amount(code):
    base = 349 if code.startswith("PRO") else 149
    months = 12 if "YEARLY" in code else 6 if "SEMIANNUAL" in code else 3 if "QUARTERLY" in code else 1
    discount = {1: 0, 3: 5, 6: 10, 12: 15}[months]
    total = round(base * months * (100 - discount) / 100, 2)
    return total, months, discount, base


def make_platform_offers():
    offers = []
    for code in OFFER_CODES:
        total, months, discount, base = offer_amount(code)
        offers.append({
            "code": code,
            "name": code.replace("_", " ").title(),
            "durationMonths": months,
            "monthlyBasePrice": base,
            "totalPrice": total,
            "discountPercent": discount,
            "currency": "TND",
            "active": True,
        })
    return offers


def make_platform_features():
    return [
        {"key": "USERS", "label": "Users"},
        {"key": "DIVISIONS", "label": "Divisions"},
        {"key": "ACTIVITIES", "label": "Activities"},
        {"key": "ACADEMY_SETTINGS", "label": "Academy Settings"},
        {"key": "SUBSCRIPTION", "label": "Subscription"},
        {"key": "PAYMENTS", "label": "Payments"},
        {"key": "NOTIFICATIONS", "label": "Notifications"},
        {"key": "REPORTS", "label": "Reports"},
        {"key": "CHATBOT", "label": "Chatbot"},
        {"key": "CHAT", "label": "Team Chat"},
    ]


def build_seed():
    sports = []
    academies = []
    divisions = []
    users = []
    trainers = []
    players = []
    activities = []
    conversations = []
    notifications = []
    academy_payments = []
    academy_user_subscription_settings = []
    scouters = []

    known_accounts = {
        "superAdmin": {"email": "boufaiedmortadha7@gmail.com", "password": "admin123"},
        "academyAdmin": {"email": "atlas-football-admin-0@seed.sports.local", "password": "admin123"},
        "trainer": {"email": "atlas-football-trainer-u9-0@seed.sports.local", "password": "trainer123"},
        "player": {"email": "atlas-football-player-u9-0@seed.sports.local", "password": "player123"},
        "scouter": {"email": "scouter-0@seed.sports.local", "password": "scouter123"},
    }

    users.append({
        "email": known_accounts["superAdmin"]["email"],
        "nom": "Boufaiedmortadha7 Test Super Admin",
        "mdp": known_accounts["superAdmin"]["password"],
        "mainRole": "SUPER_ADMIN",
        "roles": ["SUPER_ADMIN"],
        "subscriptionStartDate": iso(TODAY - timedelta(days=900)),
    })

    for display_order, (sport_code, sport) in enumerate(SPORTS.items(), start=1):
        sports.append({
            "code": sport_code,
            "name": sport["name"],
            "description": f"{sport['name']} academy program.",
            "displayOrder": display_order,
            "theme": sport["theme"],
            "divisions": sport["divisions"],
        })

        for academy_index, academy_base_name in enumerate(ACADEMY_NAMES):
            academy_name = f"{academy_base_name} {sport['name']} Academy"
            academy_slug = slugify(f"{academy_base_name}-{sport['name']}")
            city = CITIES[academy_index % len(CITIES)]
            offer_code = RNG.choice(OFFER_CODES)
            total_price, offer_months, _, _ = offer_amount(offer_code)
            subscription_start = TODAY - timedelta(days=RNG.randint(45, 420))

            academies.append({
                "name": academy_name,
                "slug": academy_slug,
                "sportCode": sport_code,
                "email": email(f"{academy_slug}-office"),
                "phone": f"+216{RNG.randint(20000000, 99999999)}",
                "address": f"{RNG.randint(1, 99)} Avenue {academy_base_name}",
                "city": city,
                "country": "Tunisia",
                "logoUrl": f"/uploads/logos/{academy_slug}.png",
                "status": "ACTIVE",
                "subscriptionStartDate": iso(subscription_start),
                "selectedPlatformOfferCode": offer_code,
            })

            academy_user_subscription_settings.append({
                "academySlug": academy_slug,
                "monthlyPrice": RNG.choice([80, 90, 100, 120]),
                "currency": "TND",
                "dueAfterDays": 7,
                "graceMonthsBeforeBlock": 2,
            })

            for admin_index in range(3):
                admin_email = email(f"{academy_slug}-admin-{admin_index}")
                users.append({
                    "email": admin_email,
                    "nom": full_name(),
                    "tel": f"+216{RNG.randint(20000000, 99999999)}",
                    "mdp": "admin123",
                    "mainRole": "ADMIN",
                    "roles": ["ADMIN"],
                    "academySlug": academy_slug,
                    "subscriptionStartDate": iso(subscription_start),
                    "adminAccess": "ALL" if admin_index == 0 else RNG.choice(["USERS", "ACTIVITIES", "CHAT"]),
                })

            invoice_count = RNG.randint(1, 3)
            for invoice_index in range(invoice_count):
                period_start = subscription_start + timedelta(days=30 * offer_months * invoice_index)
                if period_start > TODAY:
                    break
                period_end = period_start + timedelta(days=(30 * offer_months) - 1)
                academy_payments.append({
                    "academySlug": academy_slug,
                    "platformOfferCode": offer_code,
                    "amount": total_price,
                    "currency": "TND",
                    "status": "PAID" if invoice_index < invoice_count - 1 else RNG.choice(["PAID", "PENDING"]),
                    "billingPeriodStart": iso(period_start),
                    "billingPeriodEnd": iso(period_end),
                    "dueDate": iso(period_start + timedelta(days=7)),
                    "referenceCode": f"{academy_slug.upper()}-{offer_code}-{period_start.strftime('%Y%m%d')}",
                })

            chosen_divisions = RNG.sample(sport["divisions"], RNG.randint(3, 5))
            for division_order, division_name in enumerate(chosen_divisions):
                division_key = f"{academy_slug}-{slugify(division_name)}"
                trainer_email = email(f"{academy_slug}-trainer-{slugify(division_name)}-0")

                divisions.append({
                    "key": division_key,
                    "nom": division_name,
                    "categorie": division_name,
                    "academySlug": academy_slug,
                    "sportCode": sport_code,
                    "displayOrder": division_order,
                    "active": True,
                })

                users.append({
                    "email": trainer_email,
                    "nom": full_name(),
                    "tel": f"+216{RNG.randint(20000000, 99999999)}",
                    "mdp": "trainer123",
                    "mainRole": "TRAINER",
                    "roles": ["TRAINER"],
                    "academySlug": academy_slug,
                    "subscriptionStartDate": iso(subscription_start + timedelta(days=RNG.randint(0, 20))),
                })
                trainers.append({
                    "email": trainer_email,
                    "academySlug": academy_slug,
                    "divisionKey": division_key,
                    "divisionNom": division_name,
                    "speciality": f"{sport['name']} development",
                })

                conversations.append({
                    "key": f"conv-{division_key}",
                    "type": "GROUP",
                    "title": f"{academy_name} {division_name}",
                    "academySlug": academy_slug,
                    "divisionKey": division_key,
                    "divisionNom": division_name,
                    "participantsEmails": [trainer_email, email(f"{academy_slug}-admin-0"), email(f"{academy_slug}-admin-1")],
                })

                for activity_index in range(3):
                    activity_date = TODAY - timedelta(days=RNG.randint(3, 140))
                    activities.append({
                        "type": "TRAINING" if activity_index < 2 else "MATCH",
                        "date": iso(activity_date),
                        "titre": f"{sport['name']} {division_name} {'training' if activity_index < 2 else 'match'} {activity_index + 1}",
                        "description": f"Historic {sport['name'].lower()} activity for {division_name}.",
                        "lieu": f"{academy_name} main venue",
                        "trainerEmail": trainer_email,
                        "academySlug": academy_slug,
                        "divisionKey": division_key,
                    })

                player_count = RNG.randint(PLAYERS_PER_DIVISION_MIN, PLAYERS_PER_DIVISION_MAX)
                for player_index in range(player_count):
                    player_email = email(f"{academy_slug}-player-{slugify(division_name)}-{player_index}")
                    users.append({
                        "email": player_email,
                        "nom": full_name(),
                        "tel": f"+216{RNG.randint(20000000, 99999999)}",
                        "mdp": "player123",
                        "mainRole": "PLAYER",
                        "roles": ["PLAYER"],
                        "academySlug": academy_slug,
                        "subscriptionStartDate": iso(subscription_start + timedelta(days=RNG.randint(0, 60))),
                    })
                    players.append({
                        "email": player_email,
                        "academySlug": academy_slug,
                        "sportCode": sport_code,
                        "divisionKey": division_key,
                        "divisionNom": division_name,
                        "trainerEmail": trainer_email,
                        "position": RNG.choice(sport["positions"]),
                        "age": RNG.randint(8, 19),
                        "nationality": RNG.choice(["Tunisian", "Algerian", "Moroccan", "Libyan"]),
                        "height": round(RNG.uniform(128, 198), 1),
                        "weight": round(RNG.uniform(29, 92), 1),
                        "matches": RNG.randint(4, 36),
                        "goals": RNG.randint(0, 30),
                        "assists": RNG.randint(0, 18),
                        "averageRating": round(RNG.uniform(5.8, 9.4), 2),
                        "customStats": {
                            "attendanceRate": round(RNG.uniform(0.72, 0.99), 2),
                            "consistency": round(RNG.uniform(0.48, 0.96), 2),
                            "potentialSignal": round(RNG.uniform(0.35, 0.98), 2),
                        },
                    })

        for notice_index in range(ACADEMY_NOTIFICATIONS_PER_SPORT):
            notifications.append({
                "scope": "GLOBAL",
                "sportCode": sport_code,
                "title": RNG.choice(["Platform reminder", "New activity window", "Subscription notice", "Scouting bulletin"]),
                "content": RNG.choice([
                    "The compact demo seed keeps only platform-level notices.",
                    "Division activity has been refreshed for this sport.",
                    "Academy subscription summaries are available.",
                    "Scouter access remains enabled for demo accounts.",
                ]),
                "createdAt": iso(datetime.combine(TODAY - timedelta(days=RNG.randint(0, 45)), datetime.min.time())),
            })

    for scouter_index in range(20):
        scouter_email = email(f"scouter-{scouter_index}")
        users.append({
            "email": scouter_email,
            "nom": full_name(),
            "tel": f"+216{RNG.randint(20000000, 99999999)}",
            "mdp": "scouter123",
            "mainRole": "SCOUTER",
            "roles": ["SCOUTER"],
            "subscriptionStartDate": iso(TODAY - timedelta(days=RNG.randint(60, 360))),
        })
        scouters.append({
            "email": scouter_email,
            "licenseNumber": f"SCT-2026-{scouter_index:03d}",
            "speciality": RNG.choice(["Youth potential", "Goalkeepers", "Technical profiles", "Multi-sport athleticism"]),
            "active": True,
        })

    seed = {
        "meta": {
            "generatedAt": iso(datetime.now()),
            "randomSeed": 20260517,
            "mode": "compact-demo",
            "knownAccounts": known_accounts,
            "notes": "Compact deterministic seed with academies, divisions, lighter players, and no parent/payment history payloads.",
        },
        "sports": sports,
        "platformOffers": make_platform_offers(),
        "platformFeatures": make_platform_features(),
        "academies": academies,
        "academyUserSubscriptionSettings": academy_user_subscription_settings,
        "academyPayments": academy_payments,
        "roles": ["SUPER_ADMIN", "ADMIN", "PLAYER", "TRAINER", "SCOUTER"],
        "divisions": divisions,
        "users": users,
        "trainers": trainers,
        "parents": [],
        "players": players,
        "payments": [],
        "userSubscriptions": [],
        "activities": activities,
        "conversations": conversations,
        "messages": [],
        "messageReads": [],
        "notifications": notifications,
        "playerAttributeSnapshots": [],
        "playerProgressions": [],
        "scouters": scouters,
        "scouterWatchedPlayers": [],
        "scoutingReports": [],
    }
    seed["meta"]["counts"] = {key: len(value) for key, value in seed.items() if isinstance(value, list)}
    return seed


def main():
    seed = build_seed()
    for out_file in OUT_FILES:
        out_file.parent.mkdir(parents=True, exist_ok=True)
        with out_file.open("w", encoding="utf-8") as handle:
            json.dump(seed, handle, ensure_ascii=False, separators=(",", ":"))
            handle.write("\n")
        size_mb = out_file.stat().st_size / (1024 * 1024)
        print(f"Wrote {out_file} ({size_mb:.2f} MB)")
    for key, value in seed["meta"]["counts"].items():
        print(f"{key}:{value}")


if __name__ == "__main__":
    main()
