import csv
import json
import random
from datetime import date, datetime, time, timedelta
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_FILES = [
    ROOT / "sports_management_project" / "seed.prepared.json",
    ROOT / "ressources" / "files" / "Data" / "data.json",
    ROOT / "sports_management_project" / "src" / "main" / "resources" / "Files" / "Data" / "data.json",
]
SCOUTING_EXPORT_JSONL = ROOT / "scouting-ai-service" / "data" / "exports" / "player_snapshot_training_dataset.jsonl"
SCOUTING_EXPORT_CSV = ROOT / "scouting-ai-service" / "data" / "exports" / "player_snapshot_training_dataset.csv"
RANKING_EXPORT_JSONL = ROOT / "academy-ranking-ai-service" / "data" / "exports" / "academy_snapshot_training_dataset.jsonl"

RNG = random.Random(20260517)
TODAY = date(2026, 5, 17)

SPORTS = {
    "football": {
        "name": "Football",
        "divisions": ["U11", "U13", "U15", "U17"],
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
        "divisions": ["U12", "U14", "U16", "U18"],
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
        "divisions": ["U13", "U15", "U17", "U19"],
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
        "divisions": ["U13", "U15", "U17", "Senior"],
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
        "divisions": ["Orange Ball", "Green Ball", "U14", "U16"],
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

METRICS = [
    ("speed", "Speed", "PHYSICAL", 0, 100, 1.0),
    ("technical", "Technical Execution", "TECHNICAL", 0, 100, 1.25),
    ("tactical", "Tactical Understanding", "TACTICAL", 0, 100, 1.15),
    ("physical", "Physical Readiness", "PHYSICAL", 0, 100, 1.0),
    ("consistency", "Consistency", "MENTAL", 0, 100, 1.1),
    ("attendance", "Attendance Signal", "AVAILABILITY", 0, 100, 0.75),
]

ACADEMY_BASES = ["Atlas", "Carthage"]
CITIES = ["Tunis", "Sousse", "Sfax", "Nabeul", "Monastir", "Bizerte", "Ariana", "Mahdia"]
FIRST_NAMES = ["Youssef", "Adam", "Amir", "Mehdi", "Rayen", "Ilyes", "Nour", "Sami", "Malek", "Anis", "Maya", "Lina", "Ines", "Rim", "Sarra", "Yasmine"]
LAST_NAMES = ["Ben Ali", "Trabelsi", "Mansouri", "Haddad", "Bouzid", "Kammoun", "Jaziri", "Gharbi", "Chebbi", "Mbarek", "Sassi", "Hamdi"]
OFFER_CODES = ["REGULAR_MONTHLY", "PRO_QUARTERLY", "PRO_SEMIANNUAL", "PRO_YEARLY"]


def slugify(value):
    return value.lower().replace(" ", "-").replace("/", "-").replace("'", "").replace("--", "-")


def iso_date(value):
    return value.isoformat()


def iso_dt(day, hour=9, minute=0):
    return datetime.combine(day, time(hour, minute)).isoformat()


def full_name():
    return f"{RNG.choice(FIRST_NAMES)} {RNG.choice(LAST_NAMES)}"


def email(local, domain="seed.sports.local"):
    return f"{slugify(local)}@{domain}"


def clamp(value, low=0, high=100):
    return max(low, min(high, value))


def rounded(value):
    return round(float(value), 2)


def offer_amount(code):
    base = 340 if code.startswith("PRO") else 150
    months = 12 if "YEARLY" in code else 6 if "SEMIANNUAL" in code else 3 if "QUARTERLY" in code else 1
    discount = {1: 0, 3: 5, 6: 10, 12: 15}[months]
    return round(base * months * (100 - discount) / 100, 2), months, discount, base


def platform_offers():
    offers = []
    for index, code in enumerate(OFFER_CODES, start=1):
        total, months, discount, base = offer_amount(code)
        offers.append({
            "code": code,
            "name": code.replace("_", " ").title(),
            "description": f"{months} month academy access package.",
            "durationMonths": months,
            "monthlyBasePrice": base,
            "totalPrice": total,
            "discountPercent": discount,
            "currency": "TND",
            "active": True,
            "displayOrder": index,
            "effectiveFrom": "2026-01-01",
        })
    return offers


def platform_features():
    return [
        {"key": "USERS", "label": "Users", "category": "Core", "active": True},
        {"key": "DIVISIONS", "label": "Divisions", "category": "Core", "active": True},
        {"key": "ACTIVITIES", "label": "Activities", "category": "Operations", "active": True},
        {"key": "PAYMENTS", "label": "Payments", "category": "Finance", "active": True},
        {"key": "CHAT", "label": "Team Chat", "category": "Communication", "active": True},
        {"key": "SCOUTING", "label": "Scouting", "category": "AI", "active": True},
        {"key": "ACADEMY_RANKING", "label": "Academy Ranking", "category": "AI", "active": True},
    ]


def build_seed():
    seed = {
        "meta": {
            "mode": "ai-local-1mb-demo",
            "generatedAt": datetime(2026, 5, 17, 12, 0).isoformat(),
            "randomSeed": 20260517,
            "aiJoinKeys": ["playerEmail", "academySlug", "sportCode", "divisionKey"],
            "knownAccounts": {
                "superAdmin": {"email": "boufaiedmortadha7@gmail.com", "password": "admin123"},
                "academyAdmin": {"email": "atlas-football-admin@seed.sports.local", "password": "admin123"},
                "trainer": {"email": "atlas-football-trainer-u11@seed.sports.local", "password": "trainer123"},
                "parent": {"email": "atlas-football-parent-u11-0@seed.sports.local", "password": "parent123"},
                "player": {"email": "atlas-football-player-u11-0@seed.sports.local", "password": "player123"},
                "scouter": {"email": "scouter-0@seed.sports.local", "password": "scouter123"},
            },
            "localAiExports": {
                "scoutingJsonl": "scouting-ai-service/data/exports/player_snapshot_training_dataset.jsonl",
                "scoutingCsv": "scouting-ai-service/data/exports/player_snapshot_training_dataset.csv",
                "academyRankingJsonl": "academy-ranking-ai-service/data/exports/academy_snapshot_training_dataset.jsonl",
            },
        },
        "sports": [],
        "sportStatistics": [],
        "platformOffers": platform_offers(),
        "platformFeatures": platform_features(),
        "academies": [],
        "academyUserSubscriptionSettings": [],
        "academyPayments": [],
        "divisions": [],
        "users": [],
        "trainers": [],
        "parents": [],
        "players": [],
        "payments": [],
        "userSubscriptions": [],
        "activities": [],
        "conversations": [],
        "messages": [],
        "messageReads": [],
        "notifications": [],
        "playerAttributeSnapshots": [],
        "playerProgressions": [],
        "playerPerformanceObservations": [],
        "talentScores": [],
        "scouters": [],
        "scouterWatchedPlayers": [],
        "scoutingReports": [],
        "academyPerformanceScores": [],
        "aiDatasets": {"playerSnapshots": [], "academySnapshots": []},
    }

    seed["users"].append({
        "email": "boufaiedmortadha7@gmail.com",
        "nom": "Boufaiedmortadha7 Test Super Admin",
        "mdp": "admin123",
        "mainRole": "SUPER_ADMIN",
        "roles": ["SUPER_ADMIN"],
        "subscriptionStartDate": iso_date(TODAY - timedelta(days=900)),
    })

    scouter_emails = []
    for i in range(8):
        scouter_email = email(f"scouter-{i}")
        scouter_emails.append(scouter_email)
        seed["users"].append({
            "email": scouter_email,
            "nom": f"Scouter {i + 1}",
            "mdp": "scouter123",
            "mainRole": "SCOUTER",
            "roles": ["SCOUTER"],
            "subscriptionStartDate": iso_date(TODAY - timedelta(days=365 + i * 11)),
        })
        seed["scouters"].append({
            "email": scouter_email,
            "region": CITIES[i % len(CITIES)],
            "speciality": RNG.choice(["Youth potential", "Physical profile", "Technical scouting", "Multi-sport talent"]),
            "experienceLevel": RNG.choice(["JUNIOR", "SENIOR", "LEAD"]),
            "active": True,
        })

    player_records = []
    academy_summaries = []
    sport_order = 1
    academy_order = 0
    for sport_code, sport in SPORTS.items():
        seed["sports"].append({
            "code": sport_code,
            "name": sport["name"],
            "description": f"{sport['name']} development program.",
            "displayOrder": sport_order,
            "theme": sport["theme"],
            "divisions": sport["divisions"],
        })
        sport_order += 1
        for metric_order, (metric_code, metric_name, category, min_value, max_value, weight) in enumerate(METRICS, start=1):
            seed["sportStatistics"].append({
                "sportCode": sport_code,
                "code": metric_code,
                "name": metric_name,
                "description": f"{sport['name']} {metric_name.lower()} for AI scoring.",
                "dataType": "DOUBLE",
                "isRequired": False,
                "displayOrder": metric_order,
                "category": category,
                "positionGroup": None,
                "higherIsBetter": True,
                "defaultWeight": weight,
                "minValue": min_value,
                "maxValue": max_value,
                "active": True,
            })

        for academy_base in ACADEMY_BASES:
            academy_order += 1
            academy_slug = slugify(f"{academy_base}-{sport['name']}")
            academy_name = f"{academy_base} {sport['name']} Academy"
            city = CITIES[(academy_order - 1) % len(CITIES)]
            offer_code = OFFER_CODES[(academy_order - 1) % len(OFFER_CODES)]
            amount, months, _, _ = offer_amount(offer_code)
            subscription_start = TODAY - timedelta(days=45 + academy_order * 5)
            academy_admin_email = email(f"{academy_base}-{sport['name']}-admin")
            assistant_admin_email = email(f"{academy_base}-{sport['name']}-assistant-admin")

            seed["academies"].append({
                "slug": academy_slug,
                "name": academy_name,
                "email": email(academy_slug, "academies.seed.local"),
                "phone": f"+2165{academy_order:07d}",
                "address": f"{academy_order} Training Avenue",
                "city": city,
                "country": "Tunisia",
                "logoUrl": f"/assets/seed/{academy_slug}.png",
                "sportCode": sport_code,
                "subscriptionStartDate": iso_date(subscription_start),
                "platformOfferCode": offer_code,
            })
            seed["academyUserSubscriptionSettings"].append({
                "academySlug": academy_slug,
                "monthlyPrice": 55 + academy_order * 2,
                "currency": "TND",
                "dueAfterDays": 7,
                "graceMonthsBeforeBlock": 2,
                "active": True,
            })
            for payment_index in range(2):
                period_start = subscription_start + timedelta(days=payment_index * 30 * months)
                period_end = period_start + timedelta(days=30 * months - 1)
                status = "PAID" if payment_index == 0 else RNG.choice(["PAID", "PENDING", "OVERDUE"])
                seed["academyPayments"].append({
                    "academySlug": academy_slug,
                    "platformOfferCode": offer_code,
                    "billingPeriodStart": iso_date(period_start),
                    "billingPeriodEnd": iso_date(period_end),
                    "amount": amount,
                    "currency": "TND",
                    "status": status,
                    "dueDate": iso_date(period_start + timedelta(days=7)),
                    "paidAt": iso_dt(period_start + timedelta(days=RNG.randint(1, 8)), 10, 0) if status == "PAID" else None,
                    "referenceCode": f"AP-{academy_slug[:8].upper()}-{payment_index + 1}",
                    "notes": f"{offer_code} platform invoice",
                })

            for admin_email, nom, roles in [
                (academy_admin_email, f"{academy_base} {sport['name']} Director", ["ADMIN"]),
                (assistant_admin_email, f"{academy_base} {sport['name']} Operations Admin", ["ADMIN"]),
            ]:
                seed["users"].append({
                    "email": admin_email,
                    "nom": nom,
                    "tel": f"+2162{academy_order:07d}",
                    "mdp": "admin123",
                    "mainRole": "ADMIN",
                    "roles": roles,
                    "academySlug": academy_slug,
                    "subscriptionStartDate": iso_date(subscription_start),
                })

            selected_divisions = sport["divisions"][:3]
            academy_player_scores = []
            for division_index, division_name in enumerate(selected_divisions):
                division_key = slugify(f"{academy_slug}-{division_name}")
                trainer_email = email(f"{academy_base}-{sport['name']}-trainer-{division_name}")
                seed["divisions"].append({
                    "key": division_key,
                    "nom": division_name,
                    "categorie": division_name,
                    "academySlug": academy_slug,
                    "sportCode": sport_code,
                    "displayOrder": division_index + 1,
                })
                seed["users"].append({
                    "email": trainer_email,
                    "nom": f"{division_name} {sport['name']} Trainer",
                    "tel": f"+2163{academy_order:03d}{division_index:04d}",
                    "mdp": "trainer123",
                    "mainRole": "TRAINER",
                    "roles": ["TRAINER"],
                    "academySlug": academy_slug,
                    "subscriptionStartDate": iso_date(subscription_start + timedelta(days=5)),
                })
                seed["trainers"].append({
                    "email": trainer_email,
                    "academySlug": academy_slug,
                    "divisionKey": division_key,
                    "speciality": f"{sport['name']} {division_name}",
                    "experience": f"{4 + division_index} years",
                    "license": f"{sport_code[:3].upper()}-{division_name.replace(' ', '')}",
                    "notes": "Seed trainer for AI demo data.",
                })

                conversation_key = f"conv-{division_key}"
                seed["conversations"].append({
                    "key": conversation_key,
                    "title": f"{academy_name} {division_name} Group",
                    "type": "DIVISION",
                    "academySlug": academy_slug,
                    "divisionKey": division_key,
                    "participantsEmails": [academy_admin_email, assistant_admin_email, trainer_email],
                })
                for message_index in range(2):
                    message_key = f"msg-{conversation_key}-{message_index}"
                    seed["messages"].append({
                        "key": message_key,
                        "clientTempId": f"seed-{conversation_key}-{message_index}",
                        "conversationKey": conversation_key,
                        "senderEmail": trainer_email if message_index == 0 else academy_admin_email,
                        "content": "Training attendance and progress notes are updated for this group." if message_index == 0 else "Please review payment and scouting reminders before next session.",
                        "timestamp": iso_dt(TODAY - timedelta(days=12 - message_index), 18, 15 + message_index),
                        "isRead": message_index == 0,
                    })
                    seed["messageReads"].append({
                        "messageKey": message_key,
                        "userEmail": academy_admin_email if message_index == 0 else trainer_email,
                        "readAt": iso_dt(TODAY - timedelta(days=11 - message_index), 9, message_index),
                    })

                for activity_index in range(2):
                    activity_date = TODAY - timedelta(days=28 - division_index * 2 - activity_index * 7)
                    seed["activities"].append({
                        "type": "TRAINING" if activity_index == 0 else "MATCH",
                        "academySlug": academy_slug,
                        "trainerEmail": trainer_email,
                        "date": iso_date(activity_date),
                        "titre": f"{division_name} {'Training' if activity_index == 0 else 'Internal Match'}",
                        "description": "Seed activity used by ranking and scouting context.",
                        "lieu": f"{city} Center",
                        "sessionType": "TECHNICAL" if activity_index == 0 else None,
                        "objectives": "Measure role performance and progression signals.",
                        "opponent": f"{RNG.choice(ACADEMY_BASES)} Friendly Team" if activity_index == 1 else None,
                        "result": f"{RNG.randint(0, 4)}-{RNG.randint(0, 4)}" if activity_index == 1 else None,
                    })

                for player_index in range(6):
                    player_name = full_name()
                    player_email = email(f"{academy_base}-{sport['name']}-player-{division_name}-{player_index}")
                    parent_email = email(f"{academy_base}-{sport['name']}-parent-{division_name}-{player_index}")
                    age = RNG.randint(10, 18)
                    position = RNG.choice(sport["positions"])
                    attendance = clamp(RNG.gauss(82, 10), 45, 99)
                    base_skill = clamp(RNG.gauss(62, 12), 30, 92)
                    improvement = clamp(RNG.gauss(9, 5), -3, 24)
                    latest_skill = clamp(base_skill + improvement, 20, 99)
                    role_index = clamp((latest_skill * 0.55) + (attendance * 0.2) + RNG.gauss(12, 4), 20, 98)
                    potential = clamp((latest_skill * 0.45) + (improvement * 1.8) + (attendance * 0.12) + RNG.gauss(10, 5), 10, 99)
                    payment_status = RNG.choice(["PAID", "PAID", "PENDING", "OVERDUE"])
                    blocked = payment_status == "OVERDUE" and RNG.random() < 0.25
                    current_period_start = TODAY.replace(day=1)
                    current_period_end = date(TODAY.year, TODAY.month, 28)
                    player_records.append({
                        "playerEmail": player_email,
                        "parentEmail": parent_email,
                        "academySlug": academy_slug,
                        "divisionKey": division_key,
                        "sportCode": sport_code,
                        "position": position,
                        "age": age,
                        "attendance": rounded(attendance),
                        "baseSkill": rounded(base_skill),
                        "latestSkill": rounded(latest_skill),
                        "improvement": rounded(improvement),
                        "roleIndex": rounded(role_index),
                        "potential": rounded(potential),
                        "paymentStatus": payment_status,
                    })
                    academy_player_scores.append(potential)

                    seed["users"].append({
                        "email": parent_email,
                        "nom": f"Parent of {player_name}",
                        "tel": f"+2164{academy_order:03d}{division_index:01d}{player_index:03d}",
                        "mdp": "parent123",
                        "mainRole": "PARENT",
                        "roles": ["PARENT"],
                        "academySlug": academy_slug,
                        "subscriptionStartDate": iso_date(subscription_start + timedelta(days=10 + player_index)),
                    })
                    seed["parents"].append({
                        "email": parent_email,
                        "academySlug": academy_slug,
                        "linkedPlayerEmail": player_email,
                        "relation": RNG.choice(["MOTHER", "FATHER"]),
                        "paymentState": payment_status,
                    })
                    seed["users"].append({
                        "email": player_email,
                        "nom": player_name,
                        "tel": f"+2169{academy_order:03d}{division_index:01d}{player_index:03d}",
                        "mdp": "player123",
                        "mainRole": "PLAYER",
                        "roles": ["PLAYER"],
                        "academySlug": academy_slug,
                        "subscriptionStartDate": iso_date(subscription_start + timedelta(days=10 + player_index)),
                    })
                    seed["players"].append({
                        "email": player_email,
                        "academySlug": academy_slug,
                        "divisionKey": division_key,
                        "trainerEmail": trainer_email,
                        "parentEmail": parent_email,
                        "position": position,
                        "nationality": "Tunisian",
                        "age": age,
                        "height": rounded(RNG.uniform(138, 190)),
                        "weight": rounded(RNG.uniform(34, 82)),
                        "goals": RNG.randint(0, 18),
                        "assists": RNG.randint(0, 14),
                        "matches": RNG.randint(6, 28),
                        "averageRating": rounded(latest_skill / 10),
                        "customStats": {
                            "sportCode": sport_code,
                            "primaryRole": position,
                            "attendanceSignal": rounded(attendance),
                            "progressionVelocity": rounded(improvement),
                        },
                        "ranking": {
                            "score": rounded(potential),
                            "tier": "ELITE" if potential >= 82 else "CORE" if potential >= 68 else "DEVELOPING",
                        },
                    })
                    for user_email in [parent_email, player_email]:
                        seed["userSubscriptions"].append({
                            "userEmail": user_email,
                            "academySlug": academy_slug,
                            "subscriptionStartDate": iso_date(subscription_start + timedelta(days=10 + player_index)),
                            "currentPeriodStart": iso_date(current_period_start),
                            "currentPeriodEnd": iso_date(current_period_end),
                            "nextBillingDate": iso_date(TODAY.replace(day=1) + timedelta(days=31)),
                            "status": "BLOCKED" if blocked else "GRACE" if payment_status == "OVERDUE" else "ACTIVE",
                            "blockedAt": iso_dt(TODAY - timedelta(days=3), 8, 0) if blocked else None,
                        })
                    seed["payments"].append({
                        "playerEmail": player_email,
                        "parentEmail": parent_email,
                        "academySlug": academy_slug,
                        "mois": iso_date(TODAY.replace(day=1)),
                        "amount": 55 + academy_order * 2,
                        "currency": "TND",
                        "paymentType": "MONTHLY_FEE",
                        "billingPeriodStart": iso_date(current_period_start),
                        "billingPeriodEnd": iso_date(current_period_end),
                        "dueDate": iso_date(TODAY.replace(day=7)),
                        "status": payment_status,
                        "completedAt": iso_dt(TODAY.replace(day=RNG.randint(1, 10)), 11, 0) if payment_status == "PAID" else None,
                        "description": "Parent/player monthly academy subscription.",
                    })
                    first_capture = TODAY - timedelta(days=55)
                    latest_capture = TODAY - timedelta(days=5)
                    for capture_day, value, suffix in [(first_capture, base_skill, "base"), (latest_capture, latest_skill, "latest")]:
                        seed["playerAttributeSnapshots"].append({
                            "playerEmail": player_email,
                            "capturedAt": iso_dt(capture_day, 16, player_index),
                            "speed": rounded(clamp(value + RNG.gauss(0, 8))),
                            "acceleration": rounded(clamp(value + RNG.gauss(0, 7))),
                            "agility": rounded(clamp(value + RNG.gauss(0, 7))),
                            "stamina": rounded(clamp(value + RNG.gauss(0, 6))),
                            "strength": rounded(clamp(value + RNG.gauss(0, 6))),
                            "positioning": rounded(clamp(value + RNG.gauss(0, 8))),
                            "decisionMaking": rounded(clamp(value + RNG.gauss(0, 8))),
                            "vision": rounded(clamp(value + RNG.gauss(0, 9))),
                            "offBallMovement": rounded(clamp(value + RNG.gauss(0, 8))),
                            "composure": rounded(clamp(value + RNG.gauss(0, 7))),
                            "snapshotType": suffix,
                        })
                    for metric_name, old_value, new_value in [
                        ("overall_index", base_skill, latest_skill),
                        ("role_performance_index", role_index - improvement, role_index),
                    ]:
                        seed["playerProgressions"].append({
                            "playerEmail": player_email,
                            "metricName": metric_name,
                            "oldValue": rounded(clamp(old_value)),
                            "newValue": rounded(clamp(new_value)),
                            "changeRate": rounded(new_value - old_value),
                            "recordedAt": iso_dt(TODAY - timedelta(days=4), 14, player_index),
                        })
                    for obs_index, obs_day in enumerate([TODAY - timedelta(days=31), TODAY - timedelta(days=6)]):
                        obs_skill = base_skill if obs_index == 0 else latest_skill
                        seed["playerPerformanceObservations"].append({
                            "key": f"obs-{slugify(player_email)}-{obs_index}",
                            "playerEmail": player_email,
                            "academySlug": academy_slug,
                            "divisionKey": division_key,
                            "sportCode": sport_code,
                            "sourceType": "TRAINING" if obs_index == 0 else "MATCH",
                            "observedAt": iso_dt(obs_day, 17, player_index),
                            "recordedByEmail": trainer_email,
                            "summaryRating": rounded(obs_skill / 10),
                            "rolePerformanceIndex": rounded(role_index if obs_index else max(20, role_index - improvement)),
                            "confidence": rounded(0.62 + obs_index * 0.12),
                            "notes": "AI-local observation aligned with DB player and sport metric definitions.",
                            "metrics": {
                                "speed": rounded(clamp(obs_skill + RNG.gauss(0, 8))),
                                "technical": rounded(clamp(obs_skill + RNG.gauss(4, 7))),
                                "tactical": rounded(clamp(obs_skill + RNG.gauss(1, 8))),
                                "physical": rounded(clamp(obs_skill + RNG.gauss(0, 7))),
                                "consistency": rounded(clamp(role_index + RNG.gauss(0, 7))),
                                "attendance": rounded(attendance),
                            },
                        })
                    risk_level = "LOW" if potential > 75 else "MEDIUM" if potential > 55 else "HIGH"
                    seed["talentScores"].append({
                        "playerEmail": player_email,
                        "score": rounded(potential),
                        "confidence": rounded(0.66 + min(0.25, abs(improvement) / 100)),
                        "riskLevel": risk_level,
                        "generatedAt": iso_dt(TODAY - timedelta(days=2), 10, player_index),
                    })
                    seed["aiDatasets"]["playerSnapshots"].append({
                        "playerEmail": player_email,
                        "academySlug": academy_slug,
                        "divisionKey": division_key,
                        "sportCode": sport_code,
                        "position": position,
                        "age": age,
                        "latestTalentScore": rounded(potential),
                        "progressionVelocity": rounded(improvement),
                        "rolePerformanceIndex": rounded(role_index),
                        "attendanceSignal": rounded(attendance),
                        "paymentRisk": 0.85 if payment_status == "OVERDUE" else 0.35 if payment_status == "PENDING" else 0.05,
                        "observationsCount": 2,
                        "snapshotsCount": 2,
                        "label": "shortlist" if potential >= 76 or (potential >= 62 and improvement >= 12) else "monitor" if potential >= 55 else "develop",
                    })

            average_potential = sum(academy_player_scores) / max(1, len(academy_player_scores))
            activity_score = 68 + RNG.randint(0, 24)
            payment_health = 55 + RNG.randint(0, 38)
            scouting_score = 60 + RNG.randint(0, 30)
            development = rounded(average_potential)
            total = rounded(development * 0.35 + scouting_score * 0.2 + activity_score * 0.2 + payment_health * 0.15 + RNG.randint(5, 12))
            academy_summaries.append((academy_slug, sport_code, total, development, scouting_score, activity_score, payment_health))
            seed["notifications"].append({
                "academySlug": academy_slug,
                "userEmail": academy_admin_email,
                "title": "Academy ranking refreshed",
                "content": "The local AI ranking snapshot has been prepared from academy, player, payment, and activity data.",
                "createdAt": iso_dt(TODAY - timedelta(days=1), 9, 30),
                "isRead": False,
            })

    ranked = sorted(academy_summaries, key=lambda row: row[2], reverse=True)
    for rank, (academy_slug, sport_code, total, development, scouting_score, activity_score, payment_health) in enumerate(ranked, start=1):
        talent_production = rounded((development + scouting_score) / 2)
        score = {
            "academySlug": academy_slug,
            "sportCode": sport_code,
            "overallScore": total,
            "playerDevelopmentScore": development,
            "scoutingScore": scouting_score,
            "activityScore": activity_score,
            "paymentHealthScore": payment_health,
            "talentProductionScore": talent_production,
            "rankingPosition": rank,
            "generatedAt": iso_dt(TODAY - timedelta(days=1), 7, 0),
            "explanation": "Compact AI seed score using progression, scouting, activity, and payment signals.",
            "mainStrengths": "Progression velocity; active training history; scouting visibility",
            "mainWeaknesses": "Payment risk and incomplete observation depth vary by academy",
            "confidence": 0.78,
        }
        seed["academyPerformanceScores"].append(score)
        seed["aiDatasets"]["academySnapshots"].append({
            **score,
            "observationsCount": len([p for p in player_records if p["academySlug"] == academy_slug]) * 2,
            "playersCount": len([p for p in player_records if p["academySlug"] == academy_slug]),
        })

    shortlist_players = sorted(player_records, key=lambda row: row["potential"], reverse=True)[:72]
    for index, record in enumerate(shortlist_players):
        scouter_email = scouter_emails[index % len(scouter_emails)]
        seed["scouterWatchedPlayers"].append({
            "scouterEmail": scouter_email,
            "playerEmail": record["playerEmail"],
            "watchStatus": "SHORTLISTED" if record["potential"] >= 78 else "WATCHING",
            "priority": "HIGH" if record["potential"] >= 78 else "MEDIUM",
            "notes": "Seed watch record generated from local AI potential and progression fields.",
            "lastReviewedAt": iso_dt(TODAY - timedelta(days=RNG.randint(1, 9)), 12, index % 50),
        })
        if index < 45:
            created_at = TODAY - timedelta(days=RNG.randint(2, 25))
            seed["scoutingReports"].append({
                "scouterEmail": scouter_email,
                "playerEmail": record["playerEmail"],
                "academySlug": record["academySlug"],
                "technicalScore": rounded(record["latestSkill"] + RNG.gauss(0, 4)),
                "tacticalScore": rounded(record["roleIndex"] + RNG.gauss(0, 4)),
                "physicalScore": rounded(record["latestSkill"] + RNG.gauss(0, 5)),
                "mentalScore": rounded(record["attendance"] + RNG.gauss(0, 5)),
                "potentialScore": rounded(record["potential"]),
                "styleFitScore": rounded(record["roleIndex"]),
                "recommendation": "Shortlist" if record["potential"] >= 78 else "Monitor",
                "notes": "Report seeded for local scouting AI explanations.",
                "status": "SHORTLISTED" if record["potential"] >= 78 else "IN_REVIEW",
                "createdAt": iso_dt(created_at, 13, index % 40),
                "updatedAt": iso_dt(created_at + timedelta(days=1), 9, index % 40),
            })
    for index, record in enumerate(shortlist_players[:20]):
        scouter_email = scouter_emails[index % len(scouter_emails)]
        admin_email = email(f"{record['academySlug']}-admin")
        conversation_key = f"conv-scout-{index}"
        seed["conversations"].append({
            "key": conversation_key,
            "title": f"Scouting follow-up {index + 1}",
            "type": "DIRECT",
            "academySlug": record["academySlug"],
            "participantsEmails": [scouter_email, admin_email],
        })
        seed["messages"].append({
            "key": f"msg-{conversation_key}",
            "clientTempId": f"seed-{conversation_key}",
            "conversationKey": conversation_key,
            "senderEmail": scouter_email,
            "receiverEmail": admin_email,
            "content": f"Please confirm availability for {record['playerEmail']} evaluation.",
            "timestamp": iso_dt(TODAY - timedelta(days=3), 15, index),
            "isRead": index % 2 == 0,
        })
        if index % 2 == 0:
            seed["messageReads"].append({
                "messageKey": f"msg-{conversation_key}",
                "userEmail": admin_email,
                "readAt": iso_dt(TODAY - timedelta(days=2), 10, index),
            })
    for record in player_records[:40]:
        seed["notifications"].append({
            "academySlug": record["academySlug"],
            "userEmail": record["parentEmail"],
            "title": "Subscription payment reminder",
            "content": "Your current monthly academy payment state is included in this demo seed.",
            "createdAt": iso_dt(TODAY - timedelta(days=2), 8, 15),
            "isRead": record["paymentStatus"] == "PAID",
        })

    seed["meta"]["counts"] = {key: len(value) for key, value in seed.items() if isinstance(value, list)}
    return seed


def write_json(seed):
    for path in OUT_FILES:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(seed, ensure_ascii=True, separators=(",", ":")), encoding="utf-8")


def write_ai_exports(seed):
    SCOUTING_EXPORT_JSONL.parent.mkdir(parents=True, exist_ok=True)
    RANKING_EXPORT_JSONL.parent.mkdir(parents=True, exist_ok=True)
    player_rows = seed["aiDatasets"]["playerSnapshots"]
    academy_rows = seed["aiDatasets"]["academySnapshots"]
    SCOUTING_EXPORT_JSONL.write_text("\n".join(json.dumps(row, ensure_ascii=True, separators=(",", ":")) for row in player_rows) + "\n", encoding="utf-8")
    RANKING_EXPORT_JSONL.write_text("\n".join(json.dumps(row, ensure_ascii=True, separators=(",", ":")) for row in academy_rows) + "\n", encoding="utf-8")
    with SCOUTING_EXPORT_CSV.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(player_rows[0].keys()))
        writer.writeheader()
        writer.writerows(player_rows)


def main():
    seed = build_seed()
    write_json(seed)
    write_ai_exports(seed)
    sizes = {str(path.relative_to(ROOT)): path.stat().st_size for path in OUT_FILES + [SCOUTING_EXPORT_JSONL, SCOUTING_EXPORT_CSV, RANKING_EXPORT_JSONL]}
    print(json.dumps({"counts": seed["meta"]["counts"], "sizes": sizes}, indent=2))


if __name__ == "__main__":
    main()
