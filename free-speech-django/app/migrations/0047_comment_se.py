# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2017-04-07 17:23
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pcari', '0046_auto_20161205_2033'),
    ]

    operations = [
        migrations.AddField(
            model_name='comment',
            name='se',
            field=models.IntegerField(blank=True, default=0, null=True),
        ),
    ]
