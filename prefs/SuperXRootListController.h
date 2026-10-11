//
//  SuperXRootListController.h
//  根设置页。复刻原版 SuperXRootListController。
//
//  ⚠️ 原版此类的 isLicenseActivated / getActivationStateText /
//  activationStatusSpecifierWithVersionText: / alicense / activateButtonPressed_ /
//  sendPostRequestWithUUID:cdk:version:model:identifier: 全部**不在此复刻**。
//  原先的「激活状态」Cell 改为静态展示「已授权」。
//

#import "SuperXPreferencesBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuperXRootListController : SuperXPreferencesBaseController
@end

NS_ASSUME_NONNULL_END
