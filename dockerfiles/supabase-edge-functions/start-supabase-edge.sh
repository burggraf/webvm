#!/bin/sh
set -eu

cat <<'MSG'
Supabase Edge Functions runtime (experimental)
==============================================

This image prepares a Supabase project skeleton under /home/user/project and
bundles research assets to help you build a full edge runtime.

Key paths inside the VM:
  • /home/user/project/functions/hello/index.ts  – sample Deno handler.
  • /opt/supabase/README.txt                     – current limitations & next steps.
  • /opt/supabase/cli-src                        – Supabase CLI source tree for reference.

MSG

if command -v supabase >/dev/null 2>&1; then
        printf "Detected Supabase CLI: %s\n\n" "$(supabase --version || printf 'version query failed')"
else
        printf "Supabase CLI binary is not installed yet.\n"
fi

cat /opt/supabase/README.txt

cat <<'INSTR'

You can edit the function sources and run CLI commands that do not require the
Deno runtime. Serving or deploying functions will remain blocked until upstream
ships 32-bit Linux builds of both the Supabase CLI and Deno.

Dropping into an interactive shell. Type 'exit' to terminate the process.
INSTR

exec /bin/bash
