// Minimal Supabase Edge Function example for reference inside the runtime image.
// The function simply responds with a JSON payload echoing the request URL.
import { serve } from "https://deno.land/std@0.217.0/http/server.ts";

serve((request) => {
        const body = JSON.stringify({
                message: "Hello from WebVM Supabase Edge Function placeholder runtime!",
                url: request.url,
        });
        return new Response(body, {
                headers: {
                        "content-type": "application/json; charset=utf-8",
                        "cache-control": "no-store",
                },
        });
});
