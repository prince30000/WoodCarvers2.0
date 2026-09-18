export const categoriesData = [
  {
    name: 'Wall Hangings',
    slug: 'wall-hangings',
    description: 'Intricately etched wooden plaques, mandalas, jharokhas, and wall art carved from seasoned timber.',
    image: {
      url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_wall_hangings'
    },
    displayOrder: 1
  },
  {
    name: 'Wooden Toys',
    slug: 'wooden-toys',
    description: 'Safe, sustainable, heirloom-quality wooden figurines, pull toys, and traditional handcrafted play items.',
    image: {
      url: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_wooden_toys'
    },
    displayOrder: 2
  },
  {
    name: 'Frames',
    slug: 'frames',
    description: 'Bespoke hand-carved photo frames and picture showcases crafted in solid rosewood and teak.',
    image: {
      url: 'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_frames'
    },
    displayOrder: 3
  },
  {
    name: 'Decorative Stands',
    slug: 'decorative-stands',
    description: 'Artisanal display stands, candle holders, and easel pedestals carved with architectural elegance.',
    image: {
      url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_stands'
    },
    displayOrder: 4
  },
  {
    name: 'Statues',
    slug: 'statues',
    description: 'Sacred and wildlife wooden statues carved by heritage wood sculptors using single blocks of timber.',
    image: {
      url: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_statues'
    },
    displayOrder: 5
  },
  {
    name: 'Sculptures',
    slug: 'sculptures',
    description: 'Contemporary and abstract wooden statement sculptures celebrating natural grains and fluid forms.',
    image: {
      url: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_sculptures'
    },
    displayOrder: 6
  },
  {
    name: 'Home Décor',
    slug: 'home-decor',
    description: 'Wooden trays, incense holders, carved accents, and artistic tabletop objects that elevate any interior.',
    image: {
      url: 'https://images.unsplash.com/photo-1616046229478-9901c5536a45?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_home_decor'
    },
    displayOrder: 7
  },
  {
    name: 'Gifts',
    slug: 'gifts',
    description: 'Handcrafted keepsake boxes, engraved trinket sets, and miniature artisan artifacts designed for gifting.',
    image: {
      url: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80',
      publicId: 'seed/cat_gifts'
    },
    displayOrder: 8
  }
];

export const productsData = [
  {
    title: 'Hand-Carved Walnut Tree of Life Wall Medallion',
    slug: 'hand-carved-walnut-tree-of-life-wall-medallion',
    sku: 'WC-WH-001',
    categorySlug: 'wall-hangings',
    price: 3499,
    discountPercent: 15,
    stock: 14,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_tree_life_1',
        isPrimary: true,
        alt: 'Tree of life wall medallion main view'
      },
      {
        url: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_tree_life_2',
        isPrimary: false,
        alt: 'Tree of life wall medallion close-up carving'
      }
    ],
    description: 'A breathtaking handcrafted wall medallion sculpted from a single disc of seasoned dark walnut wood. Featuring the eternal Tree of Life motif with deeply etched branches, roots, and delicate foliage that cast gentle natural shadows across your living room or foyer.',
    material: 'Seasoned Dark Walnut Wood',
    dimensions: { length: 40, width: 40, height: 3.5, unit: 'cm' },
    weight: { value: 1450, unit: 'g' },
    tags: ['wall hanging', 'tree of life', 'walnut', 'carved art', 'living room'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 38
  },
  {
    title: 'Artisan Teakwood Geometric Mandala Wall Plaque',
    slug: 'artisan-teakwood-geometric-mandala-wall-plaque',
    sku: 'WC-WH-002',
    categorySlug: 'wall-hangings',
    price: 2899,
    discountPercent: 10,
    stock: 20,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1582562124811-c09040d0a901?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_mandala_1',
        isPrimary: true,
        alt: 'Geometric mandala wall plaque'
      }
    ],
    description: 'Precision hand-chiselled mandala wall panel crafted by generational woodcarvers from central India. Natural golden teakwood tones with subtle matte beeswax sealer that accentuates the organic wood grain.',
    material: 'Natural Teak Wood',
    dimensions: { length: 35, width: 35, height: 2.8, unit: 'cm' },
    weight: { value: 1100, unit: 'g' },
    tags: ['mandala', 'teakwood', 'wall art', 'geometric', 'boho'],
    isFeatured: true,
    isBestseller: false,
    isNewArrival: true,
    ratingsAverage: 4.8,
    ratingsCount: 22
  },
  {
    title: 'Vintage Carved Sheesham Floral Jharokha Mirror Frame',
    slug: 'vintage-carved-sheesham-floral-jharokha-mirror-frame',
    sku: 'WC-WH-003',
    categorySlug: 'wall-hangings',
    price: 4299,
    discountPercent: 20,
    stock: 8,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_jharokha_1',
        isPrimary: true,
        alt: 'Carved Sheesham floral jharokha'
      }
    ],
    description: 'Heritage arched jharokha window panel inspired by Rajputana palace architecture. Features intricate fretwork jaali carving with an antique burnt umber finish.',
    material: 'Indian Rosewood (Sheesham)',
    dimensions: { length: 30, width: 8, height: 48, unit: 'cm' },
    weight: { value: 2100, unit: 'g' },
    tags: ['jharokha', 'sheesham', 'traditional', 'royal', 'heritage'],
    isFeatured: false,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 45
  },
  {
    title: 'Handcrafted Beechwood Rocking Horse Toy Figurine',
    slug: 'handcrafted-beechwood-rocking-horse-toy-figurine',
    sku: 'WC-TY-001',
    categorySlug: 'wooden-toys',
    price: 1499,
    discountPercent: 0,
    stock: 25,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_horse_1',
        isPrimary: true,
        alt: 'Handcrafted wooden rocking horse'
      }
    ],
    description: 'Nostalgic desktop rocking horse carved from silky-smooth solid beechwood. Finished with food-safe plant oil and rounded edges, making it an exquisite children keepsake or study desk ornament.',
    material: 'European Beechwood',
    dimensions: { length: 22, width: 7, height: 18, unit: 'cm' },
    weight: { value: 420, unit: 'g' },
    tags: ['wooden toy', 'rocking horse', 'beechwood', 'nursery', 'heirloom'],
    isFeatured: true,
    isBestseller: false,
    isNewArrival: true,
    ratingsAverage: 4.9,
    ratingsCount: 19
  },
  {
    title: 'Traditional Channapatna Natural Lacquer Wooden Stacking Rings',
    slug: 'traditional-channapatna-natural-lacquer-stacking-rings',
    sku: 'WC-TY-002',
    categorySlug: 'wooden-toys',
    price: 999,
    discountPercent: 10,
    stock: 32,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_stacking_1',
        isPrimary: true,
        alt: 'Natural lacquer stacking rings'
      }
    ],
    description: 'Crafted in the famed toy town of Channapatna using soft Wrightia tinctoria (Ivory Wood) and polished on a hand lathe with organic vegetable dyes. 100% non-toxic and eco-friendly.',
    material: 'Wrightia Tinctoria (Ivory Wood)',
    dimensions: { length: 12, width: 12, height: 20, unit: 'cm' },
    weight: { value: 380, unit: 'g' },
    tags: ['channapatna', 'stacking toy', 'eco-friendly', 'toddler', 'montessori'],
    isFeatured: false,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.8,
    ratingsCount: 56
  },
  {
    title: 'Intricately Carved Rosewood Photo Frame (5x7 Inch)',
    slug: 'intricately-carved-rosewood-photo-frame-5x7',
    sku: 'WC-FR-001',
    categorySlug: 'frames',
    price: 1699,
    discountPercent: 12,
    stock: 18,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_frame_1',
        isPrimary: true,
        alt: 'Carved rosewood photo frame'
      }
    ],
    description: 'Showcase cherished moments in this solid rosewood frame adorned with hand-relief acanthus leaves. Supports both horizontal and vertical tabletop display or wall mounting.',
    material: 'Natural Indian Rosewood',
    dimensions: { length: 24, width: 3, height: 29, unit: 'cm' },
    weight: { value: 650, unit: 'g' },
    tags: ['photo frame', 'rosewood', 'picture frame', 'tabletop', 'hand-carved'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 31
  },
  {
    title: 'Rustic Distressed Teakwood Double Picture Frame',
    slug: 'rustic-distressed-teakwood-double-picture-frame',
    sku: 'WC-FR-002',
    categorySlug: 'frames',
    price: 1999,
    discountPercent: 15,
    stock: 15,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_frame_double',
        isPrimary: true,
        alt: 'Double picture frame'
      }
    ],
    description: 'Hinged folding double frame hand-turned in reclaimed teakwood with delicate brass hinges. Holds two 4x6 inch photos with timeless warmth.',
    material: 'Reclaimed Teakwood & Solid Brass',
    dimensions: { length: 34, width: 2.5, height: 20, unit: 'cm' },
    weight: { value: 720, unit: 'g' },
    tags: ['double frame', 'teakwood', 'vintage', 'brass accents', 'table decor'],
    isFeatured: false,
    isBestseller: false,
    isNewArrival: true,
    ratingsAverage: 4.7,
    ratingsCount: 14
  },
  {
    title: 'Hand-Turned Sheesham Pillar Candle Stands (Set of 2)',
    slug: 'hand-turned-sheesham-pillar-candle-stands-set-of-2',
    sku: 'WC-DS-001',
    categorySlug: 'decorative-stands',
    price: 2199,
    discountPercent: 18,
    stock: 12,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_candle_stands_1',
        isPrimary: true,
        alt: 'Turned sheesham pillar candle stands'
      }
    ],
    description: 'Artfully lathe-turned pair of graduated candlestick holders in dense Sheesham wood. Features brass drip cups and felted scratch-resistant protective bases for dining tables and mantels.',
    material: 'Dense Sheesham & Pure Brass Inserts',
    dimensions: { length: 11, width: 11, height: 26, unit: 'cm' },
    weight: { value: 980, unit: 'g' },
    tags: ['candle stand', 'pillar candle', 'sheesham', 'dining decor', 'set of 2'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 42
  },
  {
    title: 'Carved Teakwood Book & Tablet Pedestal Stand',
    slug: 'carved-teakwood-book-tablet-pedestal-stand',
    sku: 'WC-DS-002',
    categorySlug: 'decorative-stands',
    price: 1899,
    discountPercent: 10,
    stock: 16,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_bookstand_1',
        isPrimary: true,
        alt: 'Carved teakwood book and tablet stand'
      }
    ],
    description: 'Folding carved rehal style book stand suitable for art books, recipe tablets, or holy scriptures. Carved from a single interlocking teak hinge without nails.',
    material: 'Natural Teak Wood',
    dimensions: { length: 30, width: 18, height: 19, unit: 'cm' },
    weight: { value: 850, unit: 'g' },
    tags: ['book stand', 'tablet stand', 'teakwood', 'study', 'rehal'],
    isFeatured: false,
    isBestseller: false,
    isNewArrival: true,
    ratingsAverage: 4.8,
    ratingsCount: 16
  },
  {
    title: 'Solid Sheesham Wood Elephant Trunk-Up Prosperity Statue',
    slug: 'solid-sheesham-wood-elephant-trunk-up-prosperity-statue',
    sku: 'WC-ST-001',
    categorySlug: 'statues',
    price: 2499,
    discountPercent: 15,
    stock: 15,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_elephant_1',
        isPrimary: true,
        alt: 'Carved wooden elephant statue'
      }
    ],
    description: 'A symbol of strength and good fortune. This monolithic hand-carved elephant features delicate trunk curvature and an intricately incised howdah saddle with floral crests.',
    material: 'Solid Indian Sheesham',
    dimensions: { length: 22, width: 12, height: 24, unit: 'cm' },
    weight: { value: 1650, unit: 'g' },
    tags: ['statue', 'elephant', 'sheesham', 'feng shui', 'prosperity'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 51
  },
  {
    title: 'Handcrafted Meditating Buddha Teakwood Figurine',
    slug: 'handcrafted-meditating-buddha-teakwood-figurine',
    sku: 'WC-ST-002',
    categorySlug: 'statues',
    price: 2999,
    discountPercent: 20,
    stock: 11,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_buddha_1',
        isPrimary: true,
        alt: 'Meditating Buddha teakwood figurine'
      }
    ],
    description: 'Serene Buddha in Dhyana Mudra posture seated upon a carved lotus pedestal. Hand-rubbed with natural tung oil to bring out golden amber wood highlights.',
    material: 'Aged Teak Wood',
    dimensions: { length: 18, width: 10, height: 28, unit: 'cm' },
    weight: { value: 1350, unit: 'g' },
    tags: ['buddha', 'statue', 'zen', 'meditation', 'teakwood'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 5.0,
    ratingsCount: 64
  },
  {
    title: 'Abstract Interlocking Ribbon Wood Sculpture',
    slug: 'abstract-interlocking-ribbon-wood-sculpture',
    sku: 'WC-SC-001',
    categorySlug: 'sculptures',
    price: 3799,
    discountPercent: 10,
    stock: 7,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_sculpture_ribbon_1',
        isPrimary: true,
        alt: 'Abstract ribbon wood sculpture'
      }
    ],
    description: 'A fluid, continuous Möbius ribbon sculpture sculpted from a single solid block of Himalayan cedar wood. A captivating modern centerpiece for minimalist coffee tables and executive desks.',
    material: 'Himalayan Cedar Wood',
    dimensions: { length: 28, width: 14, height: 32, unit: 'cm' },
    weight: { value: 1800, unit: 'g' },
    tags: ['abstract', 'sculpture', 'modern', 'minimalist', 'centerpiece'],
    isFeatured: true,
    isBestseller: false,
    isNewArrival: true,
    ratingsAverage: 4.8,
    ratingsCount: 18
  },
  {
    title: 'Artisan Wooden Coaster Set with Carved Caddy (Set of 6)',
    slug: 'artisan-wooden-coaster-set-with-carved-caddy',
    sku: 'WC-HD-001',
    categorySlug: 'home-decor',
    price: 1299,
    discountPercent: 15,
    stock: 30,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1616046229478-9901c5536a45?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_coasters_1',
        isPrimary: true,
        alt: 'Handmade wooden coaster set'
      }
    ],
    description: 'Set of 6 circular drink coasters carved from durable mango wood with concentric carved patterns. Includes an open-lattice matching wooden caddy stand.',
    material: 'Seasoned Mango Wood',
    dimensions: { length: 12, width: 12, height: 9, unit: 'cm' },
    weight: { value: 550, unit: 'g' },
    tags: ['coasters', 'home decor', 'tableware', 'mango wood', 'set of 6'],
    isFeatured: false,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 78
  },
  {
    title: 'Hand-Carved Keepsake Wooden Memory Box with Brass Inlay',
    slug: 'hand-carved-keepsake-wooden-memory-box-with-brass-inlay',
    sku: 'WC-GF-001',
    categorySlug: 'gifts',
    price: 2199,
    discountPercent: 12,
    stock: 22,
    images: [
      {
        url: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=1000&q=80',
        publicId: 'seed/prod_gift_box_1',
        isPrimary: true,
        alt: 'Keepsake wooden memory box with brass inlay'
      }
    ],
    description: 'Lined with soft midnight blue velvet on the interior, this heirloom keepsake box features delicate hand-hammered brass wire inlay across its lid. Perfect for jewelry, letters, and timeless keepsakes.',
    material: 'Sheesham Wood, Brass Inlay & Velvet',
    dimensions: { length: 20, width: 13, height: 8.5, unit: 'cm' },
    weight: { value: 890, unit: 'g' },
    tags: ['gift', 'keepsake box', 'jewelry box', 'brass inlay', 'velvet'],
    isFeatured: true,
    isBestseller: true,
    isNewArrival: false,
    ratingsAverage: 4.9,
    ratingsCount: 53
  }
];
