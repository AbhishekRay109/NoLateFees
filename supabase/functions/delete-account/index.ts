// Deletes the calling user's files and account. Every table cascades from
// auth.users, so removing the user removes all their rows.
// Deploy: supabase functions deploy delete-account
import { createClient } from "npm:@supabase/supabase-js@2";

const BUCKET = "attachments";

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const jwt = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!jwt) return new Response("Unauthorized", { status: 401 });

  // SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided to every function automatically.
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false },
  });

  const { data: { user }, error } = await admin.auth.getUser(jwt);
  if (error || !user) return new Response("Unauthorized", { status: 401 });

  // Files live at {userId}/{itemId}/{file}. Collect and remove them.
  const paths: string[] = [];
  const { data: folders } = await admin.storage.from(BUCKET).list(user.id, { limit: 1000 });
  for (const folder of folders ?? []) {
    const { data: files } = await admin.storage.from(BUCKET).list(`${user.id}/${folder.name}`, { limit: 1000 });
    for (const f of files ?? []) paths.push(`${user.id}/${folder.name}/${f.name}`);
  }
  for (let i = 0; i < paths.length; i += 100) {
    await admin.storage.from(BUCKET).remove(paths.slice(i, i + 100));
  }

  const { error: delErr } = await admin.auth.admin.deleteUser(user.id);
  if (delErr) return new Response("Could not delete account", { status: 500 });

  return new Response(JSON.stringify({ deleted: true }), { headers: { "Content-Type": "application/json" } });
});
