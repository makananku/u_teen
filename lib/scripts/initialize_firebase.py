import firebase_admin
from firebase_admin import credentials, firestore
import os
import base64

# Initialize Firebase
cred = credentials.Certificate('service_account_key.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'u-teen-e88b6.appspot.com'
})

db = firestore.client()

# Product data with local image paths
products = [
    {
        'id': 'product1',
        'title': 'Soto Ayam',
        'subtitle': 'Masakan Minang',
        'time': '8 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Masakan Minang',
        'isActive': True,
        'category': 'Food',
        'localImagePath': 'images/soto_ayam.jpg'
    },
    {
        'id': 'product2',
        'title': 'Nasi Pecel',
        'subtitle': 'Masakan Minang',
        'time': '5 mins',
        'price': '15000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Masakan Minang',
        'isActive': True,
        'category': 'Food',
        'localImagePath': 'images/nasi_pecel.jpg'
    },
    {
        'id': 'product3',
        'title': 'Bakso',
        'subtitle': 'Bakso 88',
        'time': '15 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Bakso 88',
        'isActive': True,
        'category': 'Food',
        'localImagePath': 'images/bakso.jpg'
    },
    {
        'id': 'product4',
        'title': 'Mie Ayam',
        'subtitle': 'Mie Ayam Enak',
        'time': '3 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Mie Ayam Enak',
        'isActive': True,
        'category': 'Food',
        'localImagePath': 'images/mie_ayam.jpg'
    },
    {
        'id': 'product5',
        'title': 'Matcha Latte',
        'subtitle': 'KopiKu',
        'time': '10 mins',
        'price': '25000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'KopiKu',
        'isActive': True,
        'category': 'Drink',
        'localImagePath': 'images/matcha_latte.jpg'
    },
    {
        'id': 'product6',
        'title': 'Cappucino',
        'subtitle': 'KopiKu',
        'time': '6 mins',
        'price': '8000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'KopiKu',
        'isActive': True,
        'category': 'Drink',
        'localImagePath': 'images/cappucino.jpg'
    },
    {
        'id': 'product7',
        'title': 'Burger',
        'subtitle': 'Aneka Makanan',
        'time': '10 mins',
        'price': '30000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Aneka Makanan',
        'isActive': True,
        'category': 'Snack',
        'localImagePath': 'images/burger.jpg'
    },
    {
        'id': 'product8',
        'title': 'Kentang Goreng',
        'subtitle': 'Fast Food Restaurant',
        'time': '3 mins',
        'price': '12000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Fast Food Restaurant',
        'isActive': True,
        'category': 'Snack',
        'localImagePath': 'images/french_fries.jpg'
    },
]

def image_to_base64(local_path):
    """Convert image to Base64 string with size validation."""
    if not os.path.exists(local_path):
        print(f"Image not found: {local_path}")
        return ''
    try:
        with open(local_path, "rb") as image_file:
            base64_data = base64.b64encode(image_file.read()).decode('utf-8')
            # Check Base64 size (1 MB limit for Firestore)
            if len(base64_data) > 1000000:
                print(f"Image {local_path} too large for Base64 (exceeds 1 MB)")
                return ''
            return base64_data
    except Exception as e:
        print(f"Error encoding image {local_path}: {e}")
        return ''

def initialize_products(use_base64=False):
    """Initialize products in Firestore with images from Base64."""
    products_collection = db.collection('products')
    batch = db.batch()  # Use batch for atomic writes
    existing_products = {doc.id: doc.to_dict() for doc in products_collection.stream()}
    print(f"Found {len(existing_products)} existing products in Firestore")

    for product in products:
        product_id = product['id']
        local_image_path = product.pop('localImagePath')
        product_data = product.copy()  # Create a copy to avoid modifying original
        if use_base64:
            product_data['imgBase64'] = image_to_base64(local_image_path)
            if not product_data['imgBase64']:
                print(f"Skipped product {product_id} due to Base64 encoding failure")
                continue
        try:
            if product_id in existing_products:
                # Update existing product with merge
                batch.set(products_collection.document(product_id), product_data, merge=True)
                print(f"Updated product: {product_id}")
            else:
                # Add new product
                batch.set(products_collection.document(product_id), product_data)
                print(f"Initialized product: {product_id}")
        except Exception as e:
            print(f"Error processing product {product_id}: {e}")
            continue

    try:
        batch.commit()
        print("Batch commit successful")
    except Exception as e:
        print(f"Batch commit failed: {e}")

def initialize_popular_cuisines():
    """Initialize popular_cuisines collection."""
    doc_ref = db.collection('popular_cuisines').document('cuisines')
    if not doc_ref.get().exists:
        doc_ref.set({
            'items': ['Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee']
        })
        print('Popular cuisines initialized.')
    else:
        print('Popular cuisines already initialized.')

def main(use_base64=False):
    """Main function to initialize Firestore."""
    metadata_ref = db.collection('metadata').document('initialized')
    if metadata_ref.get().exists and metadata_ref.get().to_dict().get('status'):
        print('Database already initialized.')
        return

    initialize_products(use_base64)
    initialize_popular_cuisines()
    metadata_ref.set({'status': True})
    print('Database initialization completed.')

if __name__ == '__main__':
    main(use_base64=True)