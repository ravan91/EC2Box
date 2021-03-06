/**
 * Copyright 2013 Sean Kavanagh - sean.p.kavanagh6@gmail.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.ec2box.manage.action;

import com.ec2box.common.util.AuthUtil;
import com.ec2box.manage.db.SystemStatusDB;
import com.ec2box.manage.model.HostSystem;
import com.ec2box.manage.model.SchSession;
import com.ec2box.manage.util.DBUtils;
import com.ec2box.manage.util.SSHUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.commons.io.FileUtils;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.interceptor.ServletRequestAware;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * This action uploads files to selected EC2 instances
 */
public class UploadAndPushAction extends ActionSupport implements  ServletRequestAware {


    File upload;
    String uploadContentType;
    String uploadFileName;
    List<Long> idList = new ArrayList<Long>();
    String pushDir = "~";
    List<HostSystem> systemStatusList;
    HostSystem pendingSystemStatus;
    HostSystem currentSystemStatus;
    HttpServletRequest servletRequest;

    public static String UPLOAD_PATH = DBUtils.class.getClassLoader().getResource(".").getPath() + "../upload";


    @Action(value = "/admin/setUpload",
            results = {
                    @Result(name = "success", location = "/admin/upload.jsp")
            }
    )
    public String setUpload() throws Exception {
        Long userId = AuthUtil.getUserId(servletRequest.getSession());
        SystemStatusDB.setInitialSystemStatus(idList,userId);
        return SUCCESS;

    }


    @Action(value = "/admin/upload",
            results = {
                    @Result(name = "input", location = "/admin/upload.jsp"),
                    @Result(name = "success", location = "/admin/upload_result.jsp")
            }
    )
    public String upload() {


        Long userId = AuthUtil.getUserId(servletRequest.getSession());
        try {
            File destination = new File(UPLOAD_PATH, uploadFileName);
            FileUtils.copyFile(upload, destination);


            pendingSystemStatus = SystemStatusDB.getNextPendingSystem(userId);

            systemStatusList = SystemStatusDB.getAllSystemStatus(userId);


        } catch (Exception e) {
            e.printStackTrace();
            return INPUT;
        }

        return SUCCESS;
    }

    @Action(value = "/admin/push",
            results = {
                    @Result(name = "success", location = "/admin/upload_result.jsp")
            }
    )
    public String push() {


        Long userId= AuthUtil.getUserId(servletRequest.getSession());
        try {

            //get next pending system
            pendingSystemStatus = SystemStatusDB.getNextPendingSystem(userId);
            if (pendingSystemStatus != null) {
                //get session for system
                SchSession session = SecureShellAction.getUserSchSessionMap().get(userId).getSchSessionMap().get(pendingSystemStatus.getId());
                //push upload to system
                currentSystemStatus = SSHUtil.pushUpload(pendingSystemStatus, session.getSession(), UPLOAD_PATH + "/" + uploadFileName, pushDir + "/" + uploadFileName);

                //update system status
                SystemStatusDB.updateSystemStatus(currentSystemStatus,userId);

                pendingSystemStatus = SystemStatusDB.getNextPendingSystem(userId);

            }

            //if push has finished to all servers then delete uploaded file
            if (pendingSystemStatus == null) {
                File delFile = new File(UPLOAD_PATH, uploadFileName);
                FileUtils.deleteQuietly(delFile);

            }
            systemStatusList = SystemStatusDB.getAllSystemStatus(userId);


        } catch (Exception e) {
            e.printStackTrace();
        }

        return SUCCESS;
    }

    /**
     * Validates all fields for uploading a file
     */
    public void validateUpload() {

        if (uploadFileName == null || uploadFileName.trim().equals("")) {
            addFieldError("upload", "Required");

        }
        if (pushDir == null || pushDir.trim().equals("")) {
            addFieldError("pushPath", "Required");

        }

    }

    public File getUpload() {
        return upload;
    }

    public void setUpload(File upload) {
        this.upload = upload;
    }

    public String getUploadContentType() {
        return uploadContentType;
    }

    public void setUploadContentType(String uploadContentType) {
        this.uploadContentType = uploadContentType;
    }

    public String getUploadFileName() {
        return uploadFileName;
    }

    public void setUploadFileName(String uploadFileName) {
        this.uploadFileName = uploadFileName;
    }

    public String getPushDir() {
        return pushDir;
    }

    public void setPushDir(String pushDir) {
        this.pushDir = pushDir;
    }

    public List<Long> getIdList() {
        return idList;
    }

    public void setIdList(List<Long> idList) {
        this.idList = idList;
    }

    public List<HostSystem> getSystemStatusList() {
        return systemStatusList;
    }

    public void setSystemStatusList(List<HostSystem> systemStatusList) {
        this.systemStatusList = systemStatusList;
    }

    public HostSystem getPendingSystemStatus() {
        return pendingSystemStatus;
    }

    public void setPendingSystemStatus(HostSystem pendingSystemStatus) {
        this.pendingSystemStatus = pendingSystemStatus;
    }

    public HostSystem getCurrentSystemStatus() {
        return currentSystemStatus;
    }

    public void setCurrentSystemStatus(HostSystem currentSystemStatus) {
        this.currentSystemStatus = currentSystemStatus;
    }

    public HttpServletRequest getServletRequest() {
        return servletRequest;
    }

    public void setServletRequest(HttpServletRequest servletRequest) {
        this.servletRequest = servletRequest;
    }
}
