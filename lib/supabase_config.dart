import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://tdauvjigidnpfmbpltjy.supabase.co';
const String supabaseAnonKey = 'sb_publishable_CmhqRX0y3OpMeyRTfL8Ojg_edolYqWF';

Future<void> inicializarSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;