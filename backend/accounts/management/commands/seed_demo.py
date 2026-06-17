from django.core.management.base import BaseCommand

from accounts.models import Role, User
from institutional.models import ChurchPrinciple, ServiceSchedule
from ministries.models import Ministry, MinistryMembership

PRINCIPLES_TEXT = """A Igreja Batista Bíblica do Eusébio (IBBE) fundamenta sua fé e prática na \
Palavra de Deus, a Bíblia Sagrada, única regra infalível de fé e conduta.

Cremos em um só Deus, eternamente existente em três pessoas: Pai, Filho e \
Espírito Santo. Cremos na salvação pela graça mediante a fé em Jesus Cristo, \
que morreu e ressuscitou para o perdão dos pecados. Cremos no batismo por \
imersão e na Ceia do Senhor como ordenanças da igreja local. Cremos na \
igreja local como corpo de Cristo, reunida para adoração, edificação e \
cumprimento da Grande Comissão. Buscamos viver em santidade, amor e serviço \
ao próximo, aguardando a volta gloriosa de Jesus Cristo."""

SCHEDULE_ITEMS = [
    ("Domingo", "08:30", "Escola Bíblica Dominical", "Tema: Evangelismo"),
    ("Domingo", "10:00", "Culto de Adoração", "Palavra: Filipenses 1 — Pastor Ronie"),
    ("Quarta-feira", "19:30", "Culto de Oração", "Palavra: Colossenses 1 — Pastor Ronie"),
    ("Sexta-feira", "19:30", "Encontro de Mulheres", ""),
    ("Sábado", "19:00", "Encontro da Mocidade", ""),
]

MINISTRIES = [
    ("Louvor", "Repertório, tons e escalas de culto", True, True),
    ("Homens", "Encontros e discipulado", False, False),
    ("Mulheres", "Encontros e discipulado", True, False),
    ("Libras", "Acessibilidade em Libras", True, False),
    ("Pastoral", "Cuidado pastoral", False, False),
    ("PGs", "Pequenos Grupos", True, False),
    ("Aconselhamento", "Apoio e aconselhamento", False, False),
    ("Missões", "Ação missionária", True, False),
]

DEMO_USERS = [
    ("pastor.ronie", "Pastor Ronie", Role.PASTOR),
    ("lider.louvor", "Líder do Louvor", Role.LEADER),
    ("midia.ibbe", "Mídia IBBE", Role.MEDIA),
    ("membro.maria", "Maria Silva", Role.MEMBER),
]


class Command(BaseCommand):
    help = "Popula dados iniciais de demonstração: usuários, ministérios, princípios e programação."

    def handle(self, *args, **options):
        pastor = None
        for username, full_name, role in DEMO_USERS:
            first, _, last = full_name.partition(" ")
            user, created = User.objects.get_or_create(
                username=username,
                defaults={"first_name": first, "last_name": last, "role": role},
            )
            if created:
                user.set_password("ibbe@2026")
                user.save()
                self.stdout.write(f"Usuário criado: {username} / senha: ibbe@2026 (role={role})")
            if role == Role.PASTOR:
                pastor = user

        for name, description, has_schedule, has_repertoire in MINISTRIES:
            ministry, created = Ministry.objects.get_or_create(
                name=name,
                defaults={
                    "description": description,
                    "has_schedule": has_schedule,
                    "has_repertoire": has_repertoire,
                    "created_by": pastor,
                },
            )
            if created:
                MinistryMembership.objects.get_or_create(
                    ministry=ministry, user=pastor, defaults={"role": MinistryMembership.MemberRole.LEADER}
                )
                self.stdout.write(f"Ministério criado: {name}")

        ChurchPrinciple.objects.get_or_create(pk=1, defaults={"content": PRINCIPLES_TEXT})

        if not ServiceSchedule.objects.exists():
            for day, time, title, subtitle in SCHEDULE_ITEMS:
                ServiceSchedule.objects.create(day_of_week=day, time=time, title=title, subtitle=subtitle)

        self.stdout.write(self.style.SUCCESS("Seed concluído."))
