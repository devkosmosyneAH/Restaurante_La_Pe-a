'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "846c3f95016541aed63b9d3e1d61b201",
"version.json": "897cd47a40c8cc9660259a68822e4334",
"index.html": "9e755601de23d42b6da2a8f2c915d3e1",
"/": "9e755601de23d42b6da2a8f2c915d3e1",
"main.dart.js": "c59019ed65592076caebd574a05636ce",
"sqlite3.wasm": "fa7637a49a0e434f2a98f9981856d118",
"404.html": "b150a64c584f896f407175a899d6b574",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"git.txt": "8785a768f9590d6deb020ac8bd16c02b",
"README.md": "322f033e84f26184d1999cb9b2c6105c",
"favicon.png": "605e5816f11d26636d30a204b4439795",
"sqflite_sw.js": "a33648db91d964fd2b07ab8e663ee34f",
"icons/Icon-192.png": "edbf0408d73a24fc1a12910108d070b3",
"icons/Icon-maskable-192.png": "edbf0408d73a24fc1a12910108d070b3",
"icons/Icon-maskable-512.png": "0346c9957fdb34f87942c2578167d6f1",
"icons/Icon-512.png": "0346c9957fdb34f87942c2578167d6f1",
"manifest.json": "07f2968069a6d48e652c6fbc4c019e43",
"google2e5ea6bddf9d9f3e.html": "4f5fc1215904285b6082e823f7b94c05",
"sitemap.xml": "c9f222e54d34a3acfbdd7c4876412a0e",
"robots.txt": "50ae8c41f6472f99f10ab2ffc59e2fea",
".git/REBASE_HEAD": "350f9566762b25e336b485a56377fe82",
".git/ORIG_HEAD": "350f9566762b25e336b485a56377fe82",
".git/config": "f79d63310f24a70f95c1cf8811a9f6d9",
".git/objects/95/9b69846ba101141c1879baa80208d814cfe49c": "923f1e0b9d5246c63f4a86f347c381d7",
".git/objects/59/23e068688dda7e605078f0a2d411af09a8590b": "bdda39fa7d5cdc861c47455e5af57c5e",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "dc1d3b6ac68817e26c52a2b7aca98a10",
".git/objects/9e/e1919dc230d3433cce79d137c37081c974034a": "b94174a22a0644ded353026549009c74",
".git/objects/32/e798bfa411f339c7c88b06e774413948cc6b6e": "19ceed6256c38cd6cfa806510ba1c035",
".git/objects/69/ac08067e3c9bb452bc68247f10fe4d3965dbb8": "df6de7ad283c2c30a14b195e638fa47f",
".git/objects/0b/9fcf3d6c6058acc662279d9d22099086a0c78a": "e46bc161d4da3ce1d34234badc3f7a34",
".git/objects/a3/6aa0bb115cfa6ccd9b29809f8780a075f8cf64": "8d5def60a41dc14cced07f316ad2d36b",
".git/objects/bb/23b66efcaa6a20c7c6c508750de636af7efe8a": "886fd2f4655e4610cf63b2603ca2189e",
".git/objects/d0/d3dc7d88578783c5a060acd15798eecff28055": "675fcfa07a63ca00d99fcdbfe35fe0c0",
".git/objects/be/71fe4b2c81a6306153abdff0da1745c73e328f": "818f409409a7995d4f9ff568828a3df1",
".git/objects/df/13f187372445c12168bbee25e09885d860685b": "be702dc1faa63d873e9490907cad53e1",
".git/objects/a5/64218fb1416f55935d48cfd870baced3447706": "a1a79ec700cfba7be78b130702133098",
".git/objects/d6/456c0de9581ccfa3168a6c085240cc70b4dbc3": "63bc7b3e1db0f1fc7c7ea9b4ccf598ec",
".git/objects/ab/809cb208dadfda5ea04351b39faad50efe1701": "1fd20d2653b9e2c1ab3bee3f0c71a578",
".git/objects/c7/29feb2a0bd8396ab9e5f5ebfd859dc65db6b17": "e8273e5367802141fd6de88e01ad28cc",
".git/objects/ee/0e319c5539dbb17d9167d3b7194b5e1a963b42": "ab44c9734516beeebec6230aeae5d2ce",
".git/objects/fd/fc15268b19d4e0bfcdbcfb0ec4cb52093c3f24": "653cb90554fbfd2f3fc0a61a181cb6e2",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "aa30b45014e5ab878c26ecce9ea89743",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "fb2ee964a7fc17b8cba79171cb799fa3",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "0c4bbf647e92f25144f535178c7f7f15",
".git/objects/ec/9c97dd9c57ad35835ccba5ab15cc1cbb8f0271": "9f986414523442589cb627c34c0aef2f",
".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904": "c071319a7242e951039ba343446845d0",
".git/objects/pack/pack-92de45c040ce3f823ad4f7aa4874672b78c385c4.rev": "046e35e72e16544975683a1fc64cf5f0",
".git/objects/pack/pack-92de45c040ce3f823ad4f7aa4874672b78c385c4.pack": "ed908bf8c493c7246d7040ed93bfda63",
".git/objects/pack/pack-92de45c040ce3f823ad4f7aa4874672b78c385c4.idx": "4283586ef1d274d8b30bda155b11e0e6",
".git/objects/11/fe1d4e5d8b17db801679b6b340ff7d6179ecc9": "2ec4a39b1a07b5d119732a72f0146959",
".git/objects/89/2b83cc5e50d10fad7adadfaecfc798b8b0f6ad": "c8575e05c687b5a96d9527d2ee1c2380",
".git/objects/89/f76f9c28e31d65389ccc176f5f4e29b7b10bb7": "be6c1b06e52a0edd847cdf552b86e306",
".git/objects/1f/bb1f1adfbbced9b9422b6ea69a53641c2558ed": "f7a45ab9472a8326107f2733ecaee594",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "e14aa589bb7e68e3a524c297a802bde9",
".git/objects/80/430913ad2aa5ecf50eeb824c01a01ae7193b6d": "c9074418384d0250a4ba29ed85ff7bb0",
".git/objects/1a/be1bcd8a3a5578c9595ec2ae679e4ddf77506a": "8c272a9195394242d95e3c01a8b20cf2",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "dee38288e294701bf8f665ae546a43e3",
".git/objects/4c/1c9bc0def6dfeffce4d8adaaa44286796d2dad": "6d3233e152cc961ab4c42dea037894aa",
".git/objects/26/c480ff420588992cc8d93cfe64f866382edf18": "f338d34c8d0e896846b34e032c579590",
".git/objects/81/a7d6790ce714f95205bfa94a879de59c73feac": "38560643c32e2c91e2c919311839d817",
".git/objects/81/37c16ac87912a3a87415fd61cf84025122bebe": "4f0fe72f29aa47734a98a2ea43ec6fa8",
".git/objects/86/03d0a3d2a91580f77171968c7d13e73fd1482a": "dc750bd17c929d834d260dd7dc0293e7",
".git/objects/43/a20f788fa8f4539a8f4f12a11980fd1e7fc4ba": "ec5d023137339309f220e0cfb6a5db16",
".git/objects/6b/b267a71656022ba6e8e068384ab22553f0dc6b": "a781dc4b438e2800693da13abbd24082",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "9524d053d0586a5f9416552b0602a196",
".git/objects/09/67dc39ce2a0a577ea66c2fff1e6ea87655743d": "cb22ca6b4ca2049479724ef55454cf44",
".git/objects/09/cb085eee13183074751899e38dcac18229a16c": "9187ad09aa8875357bfa2cb6588598ca",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "23e8f7ce2c2856c1943e6cb51334416e",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "6d57e2d4816384a5236f4a52d9f1014b",
".git/objects/08/970e4eac0b3ee4a0ef2e1c645d176949bea311": "5cb28d75c76026af18316239742d6221",
".git/objects/63/41a33a0fe20c3f4678c3d36a08ecbf10b1505f": "4543ea9d4bbbee7273e424ae352633ea",
".git/objects/d3/cb9f9288144e376253e052858cfbdf9bb06053": "7a1109fd934a4c11c2b543503a754319",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "9dbf5b01e391c548c8343be8d1d4b04e",
".git/objects/b8/f7403db7a31af5aa5b6a972a1f531cc47274a6": "e7b5f33bffcf709ddb6181bb199e1f1f",
".git/objects/b8/a61f5afa6a1f15614ff837a62043785a5cb587": "481e5b8c1917425292fd849da884fe96",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "6a4baf0ee5d7f24d01892e880c87e9b5",
".git/objects/dc/ac908c2528f2256388b363cdfddd4863b729ac": "3e944ec4d9f204a86fbc71a0cb1756d2",
".git/objects/db/4840665ca6d8cf184a10cd4c70fc87643888eb": "7864db48f0e823224073766f6cb02eac",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "a488dd5b768f3e95bb3ded676201c413",
".git/objects/ef/44d2e24609aeb6b7f60e0e270f4317cc101f99": "2ca74cea2468029a710a08e09766dc15",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "bb2eac7ac7b6a9c500a94c9e6289e6ec",
".git/objects/f7/2a2f4d5f185b00d0b163ccde79719ec1935eeb": "0216de367b9e9fb9fda75defa95c871c",
".git/objects/e8/76152abeff5cbf70d0130cd212b097f64dea24": "960c35051ac20ea735aed468bc4b49ff",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "c3694958e54483a81b3e32ab9f84ece2",
".git/objects/f1/62604e4756dbda17a18a5e9bcabb358918d9ed": "b51033a26ee8edb07c42b81c455ffd0e",
".git/objects/e7/4dad2e96d5bacbf488ce5cebd3906835e81004": "53c76ef715328272c9e2472d5b979c89",
".git/objects/e0/7797437d096064bd90c373800dcb0f335c14b0": "786019e79ddf260dafe33297b93b2151",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "eaf69ee68e07ccd33759fba4b5e36d4e",
".git/objects/77/278196f547a57c2006752b473c0568e58cecee": "7b31f9abcc0e278a3122182eda344fcd",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "6dc767ec6498faa598b6dd7d00386498",
".git/objects/70/a3b3cfcb1bbcce1fa85a38a9332b6e6e371706": "20f626d45eb3c9e3f81b2b860aa28f84",
".git/objects/1e/bac9dd05c316b2df3dba7d3d72769cb12c9063": "6efe4b99e4ce8a9d964a79975e52c121",
".git/objects/23/637bc3573701e2ad80a6f8be31b82926b4715f": "fe2d8e778b22f092b9152a9ff9b15c75",
".git/objects/4f/0c1630c17705233861405beb4c774a3b7e3d1d": "065bb5791bd3c5797294614940c70d7d",
".git/objects/1d/cc98b36047a4c22544d09d554f39869a23588c": "0155419b040a6c00636ae9d981f085c7",
".git/objects/1c/10972eceaea5bc6ddf055d7e4caa75e01e6f8e": "16aa5ea60d4bd28a318f9d493db923b3",
".git/objects/2b/d6e087a61cba0385c89389eae9b69d70b6c525": "0ef869bdcb6934168addec0128e9ea51",
".git/objects/2b/dd70465b128b7f80be0121c2c8aff69807e6f0": "3f3bd93a784537c61b8c67daa4c3734a",
".git/objects/47/c4addf7a10de1295ebf35df274f13910765b72": "967eee38dd3018750d499812d966cc90",
".git/objects/47/70b88755af8aa1d18c8b98c30c33c8c9ef5d1f": "dda2af1206e24d35295cb69dc289e057",
".git/objects/13/68991ee27d88892b3ad4b0ac551343e83b1f5f": "c37a87a97b2f2b0005c360e37c6715db",
".git/objects/14/f9f0f11d0fbbedb2b5e3054877ee62d2294346": "9639b2513ba40fbff7cf8950150528e9",
".git/HEAD": "186a136dd52f6e63e33fa9f488bcdebb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "bdb3f64f1e489c3c41ee406637abfcb3",
".git/logs/refs/heads/main": "3021b6dffe3be4564f000910b29ce39f",
".git/logs/refs/remotes/origin/main": "3b18f676fa5afb5b60da7f3c087118f2",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "350f9566762b25e336b485a56377fe82",
".git/refs/remotes/origin/main": "350f9566762b25e336b485a56377fe82",
".git/index": "8e9b6f5a4f209aa482de6be500144b0f",
".git/COMMIT_EDITMSG": "a8297d555dd34879e8e48e1cf12acefa",
".git/FETCH_HEAD": "8a71713761d13effd1c8ab56ba8618b6",
".git/rebase-merge/git-rebase-todo.backup": "8b470dca18475c04b0bf03c0a5644880",
".git/rebase-merge/head-name": "360efc618fa1294192e18ee097c9fae4",
".git/rebase-merge/orig-head": "350f9566762b25e336b485a56377fe82",
".git/rebase-merge/git-rebase-todo": "d41d8cd98f00b204e9800998ecf8427e",
".git/rebase-merge/message": "d706c71028b249140ddb4d8f30f64916",
".git/rebase-merge/onto": "342fb0444c2f36702720cc3ca1dc23fb",
".git/rebase-merge/drop_redundant_commits": "d41d8cd98f00b204e9800998ecf8427e",
".git/rebase-merge/end": "b026324c6904b2a9cb4b88d6d61c81d1",
".git/rebase-merge/patch": "d41d8cd98f00b204e9800998ecf8427e",
".git/rebase-merge/done": "20789c09db94d187eee60e9adc580b23",
".git/rebase-merge/no-reschedule-failed-exec": "d41d8cd98f00b204e9800998ecf8427e",
".git/rebase-merge/stopped-sha": "350f9566762b25e336b485a56377fe82",
".git/rebase-merge/interactive": "d41d8cd98f00b204e9800998ecf8427e",
".git/rebase-merge/msgnum": "b026324c6904b2a9cb4b88d6d61c81d1",
".git/rebase-merge/author-script": "f65f4534457b39df58be92d959e5ea12",
"assets/AssetManifest.json": "bff8eb74f9af137380ee262bcfb8a0c2",
"assets/NOTICES": "738836d6a20e5c449c00b0f6be50ac81",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/AssetManifest.bin.json": "b2d6a2a31f780a6826f785adcc0c4bcf",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "269f971cec0d5dc864fe9ae080b19e23",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "262525e2081311609d1fdab966c82bfc",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4ffc2c53105d450be7a9f443d1653fbd",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "e27cf3ff016f0f55692530dba0a9a305",
"assets/fonts/MaterialIcons-Regular.otf": "d3ea17ff64e9d5361538d0a59559d337",
"assets/assets/database/data.db": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/images/logo_la_pena.jpg": "605e5816f11d26636d30a204b4439795",
"assets/assets/images/whatsapp_logo.png": "51aa1b1a6394348bb37db9146ec4a7f5",
"assets/assets/images/banner_la_pena.jpg": "bc636b34d649785d3100e6e4a7584dc2",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
