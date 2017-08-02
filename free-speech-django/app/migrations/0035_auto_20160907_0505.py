# -*- coding: utf-8 -*-
# Generated by Django 1.9.7 on 2016-09-07 05:05
from __future__ import unicode_literals

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('pcari', '0034_auto_20160907_0325'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprogression',
            name='personal_data',
            field=models.BooleanField(default=False),
        ),
        migrations.AlterField(
            model_name='userprogression',
            name='user',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
    ]
