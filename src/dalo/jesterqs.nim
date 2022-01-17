from std/importutils import privateAccess
import jester/request, jester/private/utils, options

when useHttpBeast:
  import httpbeast except Settings

proc query*(req: request.Request): string =
  ## Query string of request
  privateAccess(req.typeof) # Jester doesn't have this public, hack till my PR is merged
  when useHttpBeast:
    let p = req.req.path.get("")
    let queryStart = p.find('?')
    if likely(queryStart != -1):
      return p[queryStart + 1 .. ^1]
    else:
      return ""
  else:
    let u = req.req.url
    return u.query
