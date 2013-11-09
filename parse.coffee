fs = require 'fs'
csv = require 'csv'
dns = require 'dns'

# MongoDB setup
Mongolian = require 'mongolian'
mongolian = new Mongolian
ObjectId = Mongolian.ObjectId
ObjectId.prototype.toJSON = ObjectId.prototype.toString
db = mongolian.db 'ghostery-replay'
chains = db.collection 'chains'
ips = db.collection 'ips'

findAndInsertIfNotFound = (host) ->
  ips.findOne {host}, (err, body) ->
    console.error err if err
    if body?
      return body
    else
      dns.lookup host, (err, address, family) ->
        if err
          return null
        else
          ips.insert {host, address}, (err, doc) ->
            console.error err if err
            return doc

addChain = (chain) ->
  [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r] = chain
  obj =
    # Unique identifier for a page load
    pageLoadId: a
    # Unique identifier for an element within a single page load (when 0,
    # this ChainRow represents the page itself.)
    n: b
    # The host without subdomains, e.g. bar.co.uk when the host is foo.bar.co.uk
    domain: c
    # Host, e.g. foo.bar.co.uk
    host: d
    # TLD, e.g. "co.uk"
    tld: e
    # Time when this resource was loaded
    time: f # (int(f) == seconds since epoch)
    # How long it took to load this resource to load
    latency: g
    # Whether this resource loaded asynchronously
    async: h
    # MIME Type for this resource
    mimeType: i
    # Size of this resource's response body in bytes
    bodySize: j
    # Width of this resource (if it was visible on the page); None otherwise
    width: k
    # Height of this resource (if it was visible on the page);
    # None otherwise
    height: l
    # Percentage of element visible on page (when viewed with a
    # 1280x800 resolution); None if it was not visible
    pctVisible: m
    # Percentage of the page area that this element occupied; None if it was
    # not visible
    pctOfPage: n
    # Whether this element was considered an advertisement (an ad image,
    # flash file, etc.); None when it's the page itself (n == 0)
    consideredAd: o
    # App ID for this resource if it matched a Ghostery pattern
    # (match with Analyzer.appNames); None if it didn't
    appId: p
    # Whether this resource was loaded (either directly or indirectly)
    # by a resource that matched a Ghostery pattern; None when it's the page
    # itself (n == 0)
    hasIntermediary: q
    # The 'n' of the resource that spawned this resource; None if unknown
    # Note that the 'n' matches that index in the slices returned by
    # ParseChainWith.
    parentN: r

  # milliseconds in the day
  obj.time24 = +new Date(obj.time) % (24*60*60)
  console.log obj.dns = findAndInsertIfNotFound(obj.host)
  chains.insert obj, (err, doc) ->
    console.error err if err
    console.log doc

csv().from.path(__dirname + "/sample.tsv", {delimiter: "\t", escape: "\""})
.transform((row) ->
  row.unshift row.pop()
  row )
.on("record", (row, index) -> 
    addChain row
    console.log "#" + index + " " + JSON.stringify(row)
)
.on("close", (count) -> console.log "Number of lines: " + count)
.on("error", (error) -> console.log error.message)
