//
//  BleDevice.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BleDevice.h"
#import "NSStringTool.h"

@implementation BleDevice

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData andRSSI:(NSNumber *)RSSI
{
    BleDevice *per = [[BleDevice alloc] init];
//    NSString *advName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    per.peripheral = cbPeripheral;
    per.deviceName = cbPeripheral.name;
    per.uuidString = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    per.RSSI = RSSI;
    NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    if (data.length >= 10) {
        NSString *mac = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(4, 6)]];
        mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableString *mutMac = mac.mutableCopy;
        NSInteger index = mutMac.length;
        while ((index - 2) > 0) {
            index -= 2;
            [mutMac insertString:@":" atIndex:index];
        }
        per.macAddress = mutMac;
    }
    
    return per;
}

@end
