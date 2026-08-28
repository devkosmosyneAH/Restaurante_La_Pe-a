'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "89c2e12aa5136ab1c8dc54afd42c91ce",
".git/config": "66deb170fbbd1c3a1901701ae545cb86",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "ca069de1e9c410c3da72ce61ef56bbce",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "8904bbb9dd658d214e9ed87fd1bdc4b7",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b4df033551674b7c364e0a5b5311a822",
".git/logs/refs/heads/gh-pages": "b4df033551674b7c364e0a5b5311a822",
".git/logs/refs/remotes/origin/gh-pages": "dbca7556875ee4b7dff996dda2cd4c00",
".git/logs/refs/remotes/pages/gh-pages": "8ea1631cdbc01c59b6ae905b11db4694",
".git/objects/02/149792f2dee376dc51715c183b4c2f59dbbd4d": "5686cbc370db9e82e703f40d0a34dd61",
".git/objects/05/478726aa10f62f5bd0b625816d40c561cc60a0": "57a7a979f1173bf49be49b8d06d4e6d0",
".git/objects/09/67dc39ce2a0a577ea66c2fff1e6ea87655743d": "42bfb2f4963a88e4b6cfaa8460acd6bf",
".git/objects/0b/9fcf3d6c6058acc662279d9d22099086a0c78a": "0f20d8b31472ed851f3506e98bb44282",
".git/objects/11/fe1d4e5d8b17db801679b6b340ff7d6179ecc9": "39a4cf87f13c36f535ecd4c56fcbe2f4",
".git/objects/13/68991ee27d88892b3ad4b0ac551343e83b1f5f": "61fa6cd21f47d2cbd24efd815c035aa9",
".git/objects/18/d045ce8605770b22390c5ffcf969b001b2fd2b": "6a32bae41ec0364a665ad0b4ca382055",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/1c/10972eceaea5bc6ddf055d7e4caa75e01e6f8e": "0185c67dad999f49755704755e660c16",
".git/objects/1d/cc98b36047a4c22544d09d554f39869a23588c": "29ca5a5e68a8ac8f09e40d9014c18975",
".git/objects/1f/bb1f1adfbbced9b9422b6ea69a53641c2558ed": "693ad3048acf59061d68681b218c6456",
".git/objects/23/637bc3573701e2ad80a6f8be31b82926b4715f": "5f84f5c437bb2791fdc8411523eae8ff",
".git/objects/26/c480ff420588992cc8d93cfe64f866382edf18": "279f52df39862236823aee9e02e33fb5",
".git/objects/26/d91061d0beaeee9d7a8182c1458a4115a4a4dc": "93346b04be64ad3f63199fb2caf1d09b",
".git/objects/2b/daa948ee527d145b3d1723b63cde8e30332f7c": "d071f65f959807dbe44bbbd25742686b",
".git/objects/31/92bab9db86624526b8b6eba66cf56ecae1c40f": "3cdfee17d3222a39bc15bfbb9447d2f4",
".git/objects/35/d4761b578ffd61bd54b303c61673ca58423ae3": "186b96e552ce17b3f698fc348b0ad692",
".git/objects/43/486cf4947f909735cdefdcfb3bfbc8601e9670": "da0b449aebad6a692bdabc3ac3a1152c",
".git/objects/43/a20f788fa8f4539a8f4f12a11980fd1e7fc4ba": "2272cd6e1bc5d7930158153c22762386",
".git/objects/4c/1c9bc0def6dfeffce4d8adaaa44286796d2dad": "30609ab711c750070a33536aad445f77",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/4f/0c1630c17705233861405beb4c774a3b7e3d1d": "ba8161e24df4628f2ffd95ad7552df7b",
".git/objects/4f/885f82d573fc3e7270e96143531f107c9b514d": "2fdaa29e8c04be729d18b5ebce016b26",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/59/23e068688dda7e605078f0a2d411af09a8590b": "4c639d47e72ea7583765f481df793222",
".git/objects/65/6b370e731f08e2907a49f617b41f10d1765980": "ca4f179815fe3922adedb368b8b8c337",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/80/430913ad2aa5ecf50eeb824c01a01ae7193b6d": "e37dd574dd5c20df7ca3af13024c1917",
".git/objects/81/37c16ac87912a3a87415fd61cf84025122bebe": "95778554dcc57e42964319ffff712436",
".git/objects/81/a7d6790ce714f95205bfa94a879de59c73feac": "a00f6e9831218c65e92b9a493afae879",
".git/objects/84/0b44d04d972900c338801f764f7f592e6cd195": "f0befdceb11bbe1e18bc7bde99d58e8d",
".git/objects/84/9f16ba41d1b898afdc56b1786bbb9ebe12c75f": "24622605833f98d3c52604aadf08920d",
".git/objects/86/03d0a3d2a91580f77171968c7d13e73fd1482a": "dc750bd17c929d834d260dd7dc0293e7",
".git/objects/89/2b83cc5e50d10fad7adadfaecfc798b8b0f6ad": "f83ee1ad4cce7687192669e76cf4cec8",
".git/objects/89/f76f9c28e31d65389ccc176f5f4e29b7b10bb7": "0ff1b1f88ade238fe96559d6549f2d91",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/90/9cc1a46710ff6964e35067f6abda3179896665": "0904200f3e933545cf07c3a49869232f",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/9e/e1919dc230d3433cce79d137c37081c974034a": "7918dcf5b15c1ac607255918935ca48a",
".git/objects/a3/6aa0bb115cfa6ccd9b29809f8780a075f8cf64": "175cdbc7cf1aed27637b07f7404c28b7",
".git/objects/a4/8a46f199b93962ca284c2dbb181740536de0ff": "ad5e0ce6d31069563f192997ecff8df5",
".git/objects/a5/64218fb1416f55935d48cfd870baced3447706": "8a09a85a00cdbd06cff0dc4340b1f5cf",
".git/objects/a5/91a33cc7a964bf6792b5e01946fa26cf17f7cd": "bcc9b95bd48dc21c5c403465f34cc1bc",
".git/objects/a9/6c0f7b60d8ed61809a46fe3be11eecd16796b2": "781b51e599f23e55587ab108b6bb6917",
".git/objects/ab/809cb208dadfda5ea04351b39faad50efe1701": "68688a930962fa62cc28366249d2b7f5",
".git/objects/b1/0cdcfcb3e035b1902b04cffcd4fbfb8198760c": "c8237aec90190f9e3a7b52d4a5955c65",
".git/objects/b1/cd7d9fccc8408559a042d0bd190d0e5d7cde47": "583b75c3798602b52908cded1595db0a",
".git/objects/b2/0c372826c0c361f73b566601939475c0bc5ee0": "ccb758ab3ba6d4dd84226be31657787e",
".git/objects/b8/a61f5afa6a1f15614ff837a62043785a5cb587": "7b15a48850cfca7ddfeb0eab82f3d098",
".git/objects/b8/f7403db7a31af5aa5b6a972a1f531cc47274a6": "87516c384e93bf003ca622a2c0d7050e",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/bb/23b66efcaa6a20c7c6c508750de636af7efe8a": "d3457f794ddb5102585efa0e9cbd4664",
".git/objects/be/71fe4b2c81a6306153abdff0da1745c73e328f": "ef6671b85ff87f39704bf64d8a30d523",
".git/objects/c7/29feb2a0bd8396ab9e5f5ebfd859dc65db6b17": "cc111d14b554a6cad12509a0c174a78f",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/d0/d3dc7d88578783c5a060acd15798eecff28055": "74089834615c68d1f20f1402d44546c4",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/456c0de9581ccfa3168a6c085240cc70b4dbc3": "b2173b831ac3c46dbb5ba5f4cd5c3e81",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/df/13f187372445c12168bbee25e09885d860685b": "eb1753c32b7ccb6ada8f11390491736b",
".git/objects/df/1e34d3f6cc667e3e5aa1d657d4c6f102f88760": "a127d8974830ce0d6e90bed1e2dcbfc1",
".git/objects/e0/7797437d096064bd90c373800dcb0f335c14b0": "16f9b9defb16491f8c733b09b022688c",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/e8/76152abeff5cbf70d0130cd212b097f64dea24": "197ba58720c34426640479faa56296b4",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ef/44d2e24609aeb6b7f60e0e270f4317cc101f99": "f2ab54dde42295b9219c16f471fcae1f",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f7/2a2f4d5f185b00d0b163ccde79719ec1935eeb": "dde27b2a8172c138941937ab167d4633",
".git/refs/heads/gh-pages": "ac777d061f01563a9edafbc47487883c",
".git/refs/remotes/origin/gh-pages": "ac777d061f01563a9edafbc47487883c",
".git/refs/remotes/pages/gh-pages": "ac777d061f01563a9edafbc47487883c",
"404.html": "b150a64c584f896f407175a899d6b574",
"assets/AssetManifest.bin": "e27cf3ff016f0f55692530dba0a9a305",
"assets/AssetManifest.bin.json": "b2d6a2a31f780a6826f785adcc0c4bcf",
"assets/AssetManifest.json": "bff8eb74f9af137380ee262bcfb8a0c2",
"assets/assets/database/data.db": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/images/banner_la_pena.jpg": "bc636b34d649785d3100e6e4a7584dc2",
"assets/assets/images/logo_la_pena.jpg": "605e5816f11d26636d30a204b4439795",
"assets/assets/images/whatsapp_logo.png": "51aa1b1a6394348bb37db9146ec4a7f5",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/fonts/MaterialIcons-Regular.otf": "d3ea17ff64e9d5361538d0a59559d337",
"assets/NOTICES": "c4cca958ca4c7c954d7b5177948c78e4",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4ffc2c53105d450be7a9f443d1653fbd",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "262525e2081311609d1fdab966c82bfc",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "269f971cec0d5dc864fe9ae080b19e23",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "605e5816f11d26636d30a204b4439795",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "9e100fcde700c8bcaf61e89e607ec4ee",
"git.txt": "42a6c4cef91d02f21d271e555a41c57c",
"google2e5ea6bddf9d9f3e.html": "4f5fc1215904285b6082e823f7b94c05",
"icons/Icon-192.png": "edbf0408d73a24fc1a12910108d070b3",
"icons/Icon-512.png": "0346c9957fdb34f87942c2578167d6f1",
"icons/Icon-maskable-192.png": "edbf0408d73a24fc1a12910108d070b3",
"icons/Icon-maskable-512.png": "0346c9957fdb34f87942c2578167d6f1",
"index.html": "8dff0dba8a74dba1fcddc6939f952caa",
"/": "8dff0dba8a74dba1fcddc6939f952caa",
"main.dart.js": "3c18404eaf1f8508581353872b736471",
"manifest.json": "07f2968069a6d48e652c6fbc4c019e43",
"robot.txt": "50ae8c41f6472f99f10ab2ffc59e2fea",
"sitemap.xml": "c9f222e54d34a3acfbdd7c4876412a0e",
"sqflite_sw.js": "a33648db91d964fd2b07ab8e663ee34f",
"sqlite3.wasm": "fa7637a49a0e434f2a98f9981856d118",
"version.json": "897cd47a40c8cc9660259a68822e4334"};
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
