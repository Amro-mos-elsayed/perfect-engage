//
//  CryptLib.h
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <UIKit/UIKit.h>

@interface StringEncryption : NSObject

-(NSString *) encryptPlainTextWith:(NSString *)plainText key:(NSString *)key iv:(NSString *)iv;
-(NSString *) decryptCipherTextWith:(NSString *)ciperText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)generateRandomIV:(size_t)length;
-  (NSString *) md5:(NSString *) input;
-  (NSString*) sha256:(NSString *)key length:(NSInteger) length;

@end
